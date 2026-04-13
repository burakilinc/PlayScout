namespace PlayScout.Infrastructure.Auth;

using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;
using PlayScout.Application.Abstractions;
using PlayScout.Application.Auth;
using PlayScout.Application.Configuration;

public sealed class JwtAccessTokenFactory : IAccessTokenFactory
{
    private readonly JwtOptions _options;

    public JwtAccessTokenFactory(IOptions<JwtOptions> options)
    {
        _options = options.Value;
        if (string.IsNullOrWhiteSpace(_options.SigningKey) ||
            Encoding.UTF8.GetByteCount(_options.SigningKey) < 32)
        {
            throw new InvalidOperationException(
                "Jwt:SigningKey must be configured and at least 32 UTF-8 bytes for HS256.");
        }
    }

    public (string Token, DateTimeOffset ExpiresAtUtc) CreateAccessToken(Guid userId, string email, bool isGuest)
    {
        var expiresAt = DateTimeOffset.UtcNow.AddMinutes(Math.Clamp(_options.AccessTokenMinutes, 1, 120));

        var claims = new List<Claim>
        {
            new(JwtRegisteredClaimNames.Sub, userId.ToString("D")),
            new(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString("D")),
            new(AuthClaimTypes.IsGuest, isGuest ? "true" : "false"),
        };

        if (!string.IsNullOrWhiteSpace(email))
            claims.Add(new Claim(ClaimTypes.Email, email));

        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_options.SigningKey));
        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);
        var token = new JwtSecurityToken(
            issuer: _options.Issuer,
            audience: _options.Audience,
            claims: claims,
            notBefore: DateTime.UtcNow,
            expires: expiresAt.UtcDateTime,
            signingCredentials: creds);

        var handler = new JwtSecurityTokenHandler();
        return (handler.WriteToken(token), expiresAt);
    }
}
