namespace PlayScout.Infrastructure.Auth;

using System.Security.Cryptography;

internal static class RawRefreshTokenGenerator
{
    public static string Create()
    {
        var bytes = RandomNumberGenerator.GetBytes(64);
        return Convert.ToBase64String(bytes)
            .TrimEnd('=')
            .Replace('+', '-')
            .Replace('/', '_');
    }
}
