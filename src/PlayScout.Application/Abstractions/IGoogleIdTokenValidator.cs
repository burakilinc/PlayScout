namespace PlayScout.Application.Abstractions;

/// <summary>Validates a Google ID token and returns stable subject + email claims.</summary>
public interface IGoogleIdTokenValidator
{
    Task<GoogleIdTokenPayload?> ValidateAsync(string idToken, CancellationToken cancellationToken = default);
}

public sealed record GoogleIdTokenPayload(string Subject, string Email, string? Name, string? PictureUrl);
