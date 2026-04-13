namespace PlayScout.Application.Configuration;

/// <summary>Google Sign-In (web / mobile client id used as JWT audience).</summary>
public sealed class GoogleAuthOptions
{
    public const string SectionName = "Google";

    /// <summary>OAuth 2.0 client id (e.g. Android/iOS/Web) whose tokens you accept.</summary>
    public string ClientId { get; set; } = string.Empty;
}
