namespace PlayScout.Application.Abstractions;

/// <summary>Loads cached translation rows or generates and persists new ones; originals are never modified.</summary>
public interface IReviewTranslationService
{
    /// <summary>
    /// Returns text suitable for display in <paramref name="requestedLanguage"/> (normalized primary subtag).
    /// Persists a new row when a machine translation is produced.
    /// </summary>
    Task<ResolvedReviewText> GetDisplayTextAsync(
        Guid venueReviewId,
        string originalText,
        string originalLanguage,
        string requestedLanguage,
        CancellationToken cancellationToken);

    /// <summary>Resolves display strings for many reviews with one cache query and batched persistence.</summary>
    Task<IReadOnlyDictionary<Guid, ResolvedReviewText>> GetDisplayTextsAsync(
        IReadOnlyList<ReviewTranslationSource> sources,
        string requestedLanguage,
        CancellationToken cancellationToken);
}

public sealed record ReviewTranslationSource(Guid ReviewId, string OriginalText, string OriginalLanguage);

public sealed record ResolvedReviewText(string DisplayText, bool IsTranslated, string? TranslatedFromLanguage);
