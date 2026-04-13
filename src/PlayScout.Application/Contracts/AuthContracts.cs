namespace PlayScout.Application.Contracts;

public sealed record RegisterRequest(string Email, string Password, string? DisplayName = null);

public sealed record LoginRequest(string Email, string Password);

public sealed record RefreshRequest(string RefreshToken);

public sealed record GoogleLoginRequest(string IdToken);

/// <summary>Reserved for Sign in with Apple (structure only in this phase).</summary>
public sealed record AppleLoginRequest(string IdentityToken, string? AuthorizationCode, string? UserIdentifier);

public sealed record TokenResponse(
    string AccessToken,
    string RefreshToken,
    DateTimeOffset AccessTokenExpiresAtUtc,
    DateTimeOffset RefreshTokenExpiresAtUtc,
    Guid UserId,
    bool IsGuest);
