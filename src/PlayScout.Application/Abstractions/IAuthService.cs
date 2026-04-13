namespace PlayScout.Application.Abstractions;

using PlayScout.Application.Contracts;

public interface IAuthService
{
    Task<(bool Success, TokenResponse? Tokens, IReadOnlyDictionary<string, string[]>? ValidationErrors)> RegisterAsync(
        RegisterRequest request,
        CancellationToken cancellationToken = default);

    Task<(bool Success, TokenResponse? Tokens, string? Error)> LoginAsync(
        LoginRequest request,
        CancellationToken cancellationToken = default);

    Task<(bool Success, TokenResponse? Tokens, string? Error)> RefreshAsync(
        RefreshRequest request,
        CancellationToken cancellationToken = default);

    Task<TokenResponse> CreateGuestSessionAsync(CancellationToken cancellationToken = default);

    Task<(bool Success, TokenResponse? Tokens, string? Error)> LoginWithGoogleAsync(
        GoogleLoginRequest request,
        CancellationToken cancellationToken = default);

    Task<(bool Success, TokenResponse? Tokens, string? Error)> LoginWithAppleAsync(
        AppleLoginRequest request,
        CancellationToken cancellationToken = default);
}
