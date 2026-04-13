namespace PlayScout.Infrastructure.Auth;

using Google.Apis.Auth;
using Microsoft.Extensions.Options;
using PlayScout.Application.Abstractions;
using PlayScout.Application.Configuration;

public sealed class GoogleIdTokenValidator : IGoogleIdTokenValidator
{
    private readonly GoogleAuthOptions _options;

    public GoogleIdTokenValidator(IOptions<GoogleAuthOptions> options) =>
        _options = options.Value;

    public async Task<GoogleIdTokenPayload?> ValidateAsync(string idToken, CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(_options.ClientId))
            return null;

        try
        {
            var settings = new GoogleJsonWebSignature.ValidationSettings
            {
                Audience = new[] { _options.ClientId },
            };

            var payload = await GoogleJsonWebSignature.ValidateAsync(idToken, settings);

            if (string.IsNullOrWhiteSpace(payload.Subject))
                return null;

            var email = payload.Email ?? string.Empty;
            if (string.IsNullOrWhiteSpace(email))
                return null;

            return new GoogleIdTokenPayload(payload.Subject, email, payload.Name, payload.Picture);
        }
        catch (Exception)
        {
            return null;
        }
    }
}
