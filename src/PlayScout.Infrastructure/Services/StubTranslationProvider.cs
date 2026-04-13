namespace PlayScout.Infrastructure.Services;

using PlayScout.Application.Abstractions;

/// <summary>Deterministic stub translator for development; swap for a real provider when API keys are configured.</summary>
public sealed class StubTranslationProvider : ITranslationProvider
{
    public string ProviderKey => "stub";

    public Task<string> TranslateAsync(
        string text,
        string sourceLanguage,
        string targetLanguage,
        CancellationToken cancellationToken)
    {
        if (string.Equals(sourceLanguage, targetLanguage, StringComparison.OrdinalIgnoreCase))
            return Task.FromResult(text);

        // Deterministic, obviously machine-generated — never mistaken for human editorial.
        var body = text.Trim();
        var translated = $"[{targetLanguage}] {body}";
        return Task.FromResult(translated);
    }
}
