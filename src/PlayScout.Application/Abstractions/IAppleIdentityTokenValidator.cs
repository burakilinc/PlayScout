namespace PlayScout.Application.Abstractions;

/// <summary>Apple Sign In — abstraction for future JWKS + issuer validation.</summary>
public interface IAppleIdentityTokenValidator
{
    Task<AppleIdentityTokenResult> ValidateAsync(
        string identityToken,
        CancellationToken cancellationToken = default);
}

public sealed record AppleIdentityTokenResult(
    bool Success,
    string? Subject,
    string? Email,
    string ErrorCode,
    string? Message);
