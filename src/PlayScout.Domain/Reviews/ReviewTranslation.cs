namespace PlayScout.Domain.Reviews;

using PlayScout.Domain.Common;

/// <summary>
/// Cached machine or human translation of a review for a target UI language.
/// </summary>
public sealed class ReviewTranslation : Entity
{
    public Guid VenueReviewId { get; private init; }

    /// <summary>ISO 639-1 / BCP 47 for translated text.</summary>
    public string LanguageCode { get; private set; }

    public string TranslatedText { get; private set; }

    public string? TranslationProvider { get; private set; }

    public DateTimeOffset CachedAt { get; private set; }

    public ReviewTranslation(Guid venueReviewId, string languageCode, string translatedText, string? translationProvider)
    {
        VenueReviewId = venueReviewId;
        LanguageCode = languageCode;
        TranslatedText = translatedText;
        TranslationProvider = translationProvider;
        CachedAt = DateTimeOffset.UtcNow;
    }

    private ReviewTranslation()
    {
        LanguageCode = null!;
        TranslatedText = null!;
    }

    internal void ReplaceText(string translatedText, string? provider)
    {
        TranslatedText = translatedText;
        TranslationProvider = provider;
        CachedAt = DateTimeOffset.UtcNow;
    }
}
