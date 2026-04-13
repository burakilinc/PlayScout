namespace PlayScout.Domain.Auth;

using PlayScout.Domain.Common;

/// <summary>
/// Stores only a cryptographic hash of the refresh token (never the raw token).
/// </summary>
public sealed class RefreshToken : Entity
{
    public Guid UserId { get; private init; }

    /// <summary>SHA-256 (hex) of the raw refresh token.</summary>
    public string TokenHash { get; private set; }

    public DateTimeOffset ExpiresAt { get; private init; }

    public DateTimeOffset? RevokedAt { get; private set; }

    public Guid? ReplacedByTokenId { get; private set; }

    public string? RevokedReason { get; private set; }

    public RefreshToken(Guid userId, string tokenHash, DateTimeOffset expiresAt)
    {
        UserId = userId;
        TokenHash = tokenHash;
        ExpiresAt = expiresAt;
    }

    private RefreshToken()
    {
        TokenHash = null!;
    }

    public bool IsActive(DateTimeOffset utcNow) =>
        RevokedAt is null && utcNow <= ExpiresAt;

    public void Revoke(string? reason, Guid? replacedByTokenId)
    {
        RevokedAt = DateTimeOffset.UtcNow;
        RevokedReason = reason;
        ReplacedByTokenId = replacedByTokenId;
        UpdatedAt = RevokedAt;
    }
}
