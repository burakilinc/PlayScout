namespace PlayScout.Infrastructure.Auth;

using System.Data;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using PlayScout.Application.Abstractions;
using PlayScout.Application.Contracts;
using PlayScout.Application.Configuration;
using PlayScout.Domain.Auth;
using PlayScout.Domain.Users;
using PlayScout.Infrastructure.Persistence;

public sealed class AuthService : IAuthService
{
    private readonly PlayScoutDbContext _db;
    private readonly IAccessTokenFactory _accessTokenFactory;
    private readonly IPasswordHasher<User> _passwordHasher;
    private readonly IGoogleIdTokenValidator _googleIdTokenValidator;
    private readonly IAppleIdentityTokenValidator _appleIdentityTokenValidator;
    private readonly JwtOptions _jwtOptions;
    private readonly GoogleAuthOptions _googleAuthOptions;

    public AuthService(
        PlayScoutDbContext db,
        IAccessTokenFactory accessTokenFactory,
        IPasswordHasher<User> passwordHasher,
        IGoogleIdTokenValidator googleIdTokenValidator,
        IAppleIdentityTokenValidator appleIdentityTokenValidator,
        IOptions<JwtOptions> jwtOptions,
        IOptions<GoogleAuthOptions> googleAuthOptions)
    {
        _db = db;
        _accessTokenFactory = accessTokenFactory;
        _passwordHasher = passwordHasher;
        _googleIdTokenValidator = googleIdTokenValidator;
        _appleIdentityTokenValidator = appleIdentityTokenValidator;
        _jwtOptions = jwtOptions.Value;
        _googleAuthOptions = googleAuthOptions.Value;
    }

    public async Task<(bool Success, TokenResponse? Tokens, IReadOnlyDictionary<string, string[]>? ValidationErrors)> RegisterAsync(
        RegisterRequest request,
        CancellationToken cancellationToken = default)
    {
        var email = NormalizeEmail(request.Email);
        if (await _db.Users.AnyAsync(u => u.Email == email, cancellationToken))
        {
            return (false, null, new Dictionary<string, string[]>
            {
                ["Email"] = ["This email is already registered."],
            });
        }

        var user = new User(email, "en", isGuest: false, displayName: request.DisplayName);
        var hash = _passwordHasher.HashPassword(user, request.Password);
        user.SetPasswordHash(hash);
        _db.Users.Add(user);
        await _db.SaveChangesAsync(cancellationToken);

        var tokens = await IssueTokensForUserAsync(user, cancellationToken);
        return (true, tokens, null);
    }

    public async Task<(bool Success, TokenResponse? Tokens, string? Error)> LoginAsync(
        LoginRequest request,
        CancellationToken cancellationToken = default)
    {
        var email = NormalizeEmail(request.Email);
        var user = await _db.Users.FirstOrDefaultAsync(u => u.Email == email, cancellationToken);
        if (user is null)
            return (false, null, "invalid_credentials");

        if (user.IsGuest)
            return (false, null, "guest_must_use_refresh_or_register");

        if (string.IsNullOrEmpty(user.PasswordHash))
            return (false, null, "invalid_credentials");

        var verify = _passwordHasher.VerifyHashedPassword(user, user.PasswordHash, request.Password);
        if (verify is PasswordVerificationResult.Failed)
            return (false, null, "invalid_credentials");

        if (verify == PasswordVerificationResult.SuccessRehashNeeded)
        {
            user.SetPasswordHash(_passwordHasher.HashPassword(user, request.Password));
            await _db.SaveChangesAsync(cancellationToken);
        }

        var tokens = await IssueTokensForUserAsync(user, cancellationToken);
        return (true, tokens, null);
    }

    public async Task<(bool Success, TokenResponse? Tokens, string? Error)> RefreshAsync(
        RefreshRequest request,
        CancellationToken cancellationToken = default)
    {
        var hash = RefreshTokenHasher.Hash(request.RefreshToken);
        await using var tx =
            await _db.Database.BeginTransactionAsync(IsolationLevel.Serializable, cancellationToken);

        var token = await _db.RefreshTokens
            .FirstOrDefaultAsync(t => t.TokenHash == hash, cancellationToken);

        if (token is null)
        {
            await tx.RollbackAsync(cancellationToken);
            return (false, null, "invalid_refresh_token");
        }

        if (!token.IsActive(DateTimeOffset.UtcNow))
        {
            await tx.RollbackAsync(cancellationToken);
            return (false, null, "refresh_token_expired_or_revoked");
        }

        var user = await _db.Users.FirstOrDefaultAsync(u => u.Id == token.UserId, cancellationToken);
        if (user is null)
        {
            await tx.RollbackAsync(cancellationToken);
            return (false, null, "user_not_found");
        }

        var newRaw = RawRefreshTokenGenerator.Create();
        var newHash = RefreshTokenHasher.Hash(newRaw);
        var refreshDays = Math.Clamp(_jwtOptions.RefreshTokenDays, 1, 180);
        var newToken = new RefreshToken(user.Id, newHash, DateTimeOffset.UtcNow.AddDays(refreshDays));
        _db.RefreshTokens.Add(newToken);
        await _db.SaveChangesAsync(cancellationToken);

        token.Revoke(reason: "rotated", replacedByTokenId: newToken.Id);
        await _db.SaveChangesAsync(cancellationToken);
        await tx.CommitAsync(cancellationToken);

        var (access, accessExp) = _accessTokenFactory.CreateAccessToken(user.Id, user.Email, user.IsGuest);
        return (true, new TokenResponse(
            access,
            newRaw,
            accessExp,
            newToken.ExpiresAt,
            user.Id,
            user.IsGuest), null);
    }

    public async Task<TokenResponse> CreateGuestSessionAsync(CancellationToken cancellationToken = default)
    {
        var id = Guid.NewGuid();
        var email = $"guest-{id:N}@guest.playscout.local";
        var user = new User(email, "en", isGuest: true, displayName: "Guest");
        _db.Users.Add(user);
        await _db.SaveChangesAsync(cancellationToken);
        return await IssueTokensForUserAsync(user, cancellationToken);
    }

    public async Task<(bool Success, TokenResponse? Tokens, string? Error)> LoginWithGoogleAsync(
        GoogleLoginRequest request,
        CancellationToken cancellationToken = default)
    {
        var payload = await _googleIdTokenValidator.ValidateAsync(request.IdToken, cancellationToken);
        if (payload is null)
        {
            if (string.IsNullOrWhiteSpace(_googleAuthOptions.ClientId))
                return (false, null, "google_oauth_not_configured");

            return (false, null, "invalid_or_untrusted_google_token");
        }

        var existingByGoogle = await _db.Users.FirstOrDefaultAsync(
            u => u.GoogleSubject == payload.Subject,
            cancellationToken);

        if (existingByGoogle is not null)
            return (true, await IssueTokensForUserAsync(existingByGoogle, cancellationToken), null);

        var normalizedEmail = NormalizeEmail(payload.Email);
        var existingByEmail = await _db.Users.FirstOrDefaultAsync(
            u => u.Email == normalizedEmail,
            cancellationToken);

        if (existingByEmail is not null)
        {
            if (!string.IsNullOrEmpty(existingByEmail.GoogleSubject) &&
                existingByEmail.GoogleSubject != payload.Subject)
                return (false, null, "email_linked_to_different_google_account");

            existingByEmail.SetOAuthGoogle(payload.Subject);
            if (string.IsNullOrWhiteSpace(existingByEmail.DisplayName) && !string.IsNullOrWhiteSpace(payload.Name))
                existingByEmail.SetDisplayName(payload.Name);

            await _db.SaveChangesAsync(cancellationToken);
            return (true, await IssueTokensForUserAsync(existingByEmail, cancellationToken), null);
        }

        var user = new User(
            normalizedEmail,
            "en",
            isGuest: false,
            displayName: payload.Name,
            passwordHash: null,
            googleSubject: payload.Subject);

        _db.Users.Add(user);
        await _db.SaveChangesAsync(cancellationToken);
        return (true, await IssueTokensForUserAsync(user, cancellationToken), null);
    }

    public async Task<(bool Success, TokenResponse? Tokens, string? Error)> LoginWithAppleAsync(
        AppleLoginRequest request,
        CancellationToken cancellationToken = default)
    {
        var result = await _appleIdentityTokenValidator.ValidateAsync(request.IdentityToken, cancellationToken);
        if (!result.Success)
            return (false, null, result.ErrorCode);

        return (false, null, "apple_login_not_implemented");
    }

    private async Task<TokenResponse> IssueTokensForUserAsync(User user, CancellationToken cancellationToken)
    {
        var (access, accessExp) = _accessTokenFactory.CreateAccessToken(user.Id, user.Email, user.IsGuest);
        var rawRefresh = RawRefreshTokenGenerator.Create();
        var hash = RefreshTokenHasher.Hash(rawRefresh);
        var refreshDays = Math.Clamp(_jwtOptions.RefreshTokenDays, 1, 180);
        var entity = new RefreshToken(user.Id, hash, DateTimeOffset.UtcNow.AddDays(refreshDays));
        _db.RefreshTokens.Add(entity);
        await _db.SaveChangesAsync(cancellationToken);

        return new TokenResponse(
            access,
            rawRefresh,
            accessExp,
            entity.ExpiresAt,
            user.Id,
            user.IsGuest);
    }

    private static string NormalizeEmail(string email) => email.Trim().ToLowerInvariant();
}
