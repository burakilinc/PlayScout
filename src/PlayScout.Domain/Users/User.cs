namespace PlayScout.Domain.Users;

using PlayScout.Domain.Common;

/// <summary>
/// Application user (JWT subject). Authentication details live in Infrastructure/Identity.
/// </summary>
public sealed class User : Entity
{
    public string Email { get; private set; }

    public string? DisplayName { get; private set; }

    public string? GoogleSubject { get; private set; }

    public string? AppleSubject { get; private set; }

    public string? PasswordHash { get; private set; }

    public string PreferredLanguage { get; private set; }

    public bool IsGuest { get; private set; }

    public User(
        string email,
        string preferredLanguage,
        bool isGuest,
        string? displayName = null,
        string? passwordHash = null,
        string? googleSubject = null,
        string? appleSubject = null)
    {
        Email = email;
        PreferredLanguage = preferredLanguage;
        IsGuest = isGuest;
        DisplayName = displayName;
        PasswordHash = passwordHash;
        GoogleSubject = googleSubject;
        AppleSubject = appleSubject;
    }

    private User()
    {
        Email = null!;
        PreferredLanguage = "en";
    }

    public void SetOAuthGoogle(string subject) => GoogleSubject = subject;

    public void SetOAuthApple(string subject) => AppleSubject = subject;

    public void UpgradeFromGuest(string email, string? passwordHash)
    {
        IsGuest = false;
        Email = email;
        PasswordHash = passwordHash;
    }

    public void SetPasswordHash(string passwordHash) => PasswordHash = passwordHash;

    public void SetDisplayName(string? displayName) => DisplayName = displayName;
}
