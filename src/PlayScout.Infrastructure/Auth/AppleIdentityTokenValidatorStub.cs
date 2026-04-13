namespace PlayScout.Infrastructure.Auth;

using PlayScout.Application.Abstractions;

/// <summary>
/// Placeholder until Apple JWKS + issuer validation is wired (team id, key id, private key flow).
/// </summary>
public sealed class AppleIdentityTokenValidatorStub : IAppleIdentityTokenValidator
{
    public Task<AppleIdentityTokenResult> ValidateAsync(
        string identityToken,
        CancellationToken cancellationToken = default)
    {
        _ = identityToken;
        return Task.FromResult(
            new AppleIdentityTokenResult(
                Success: false,
                Subject: null,
                Email: null,
                ErrorCode: "APPLE_SIGN_IN_NOT_CONFIGURED",
                Message: "Apple Sign In validation is not configured yet."));
    }
}
