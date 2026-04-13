namespace PlayScout.Application.Abstractions;

/// <summary>External or stub machine translation. Implementations must never mutate persisted originals.</summary>
public interface ITranslationProvider
{
    string ProviderKey { get; }

    /// <param name="sourceLanguage">Normalized primary language (e.g. en).</param>
    /// <param name="targetLanguage">Normalized primary language.</param>
    Task<string> TranslateAsync(
        string text,
        string sourceLanguage,
        string targetLanguage,
        CancellationToken cancellationToken);
}
