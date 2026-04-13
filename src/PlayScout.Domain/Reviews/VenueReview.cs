namespace PlayScout.Domain.Reviews;

using PlayScout.Domain.Common;

public sealed class VenueReview : Entity
{
    public Guid VenueId { get; private init; }

    public Guid UserId { get; private init; }

    public int RatingStars { get; private set; }

    public string OriginalText { get; private set; }

    /// <summary>ISO 639-1 (e.g. en, tr) for original review text.</summary>
    public string OriginalLanguage { get; private set; }

    /// <summary>Optional structured score 1–5.</summary>
    public byte? CleanlinessScore { get; private set; }

    /// <summary>Optional structured score 1–5.</summary>
    public byte? SafetyScore { get; private set; }

    /// <summary>Optional structured score 1–5.</summary>
    public byte? SuitabilitySmallChildrenScore { get; private set; }

    private readonly List<ReviewTranslation> reviewTranslations = new();

    public IReadOnlyCollection<ReviewTranslation> Translations => reviewTranslations;

    public VenueReview(
        Guid venueId,
        Guid userId,
        int ratingStars,
        string originalText,
        string originalLanguage,
        byte? cleanlinessScore = null,
        byte? safetyScore = null,
        byte? suitabilitySmallChildrenScore = null)
    {
        if (ratingStars is < 1 or > 5)
            throw new ArgumentOutOfRangeException(nameof(ratingStars));

        ValidateOptionalScore(cleanlinessScore, nameof(cleanlinessScore));
        ValidateOptionalScore(safetyScore, nameof(safetyScore));
        ValidateOptionalScore(suitabilitySmallChildrenScore, nameof(suitabilitySmallChildrenScore));

        VenueId = venueId;
        UserId = userId;
        RatingStars = ratingStars;
        OriginalText = originalText;
        OriginalLanguage = originalLanguage;
        CleanlinessScore = cleanlinessScore;
        SafetyScore = safetyScore;
        SuitabilitySmallChildrenScore = suitabilitySmallChildrenScore;
    }

    private VenueReview()
    {
        OriginalText = null!;
        OriginalLanguage = null!;
    }

    public void UpsertTranslation(string languageCode, string translatedText, string? provider)
    {
        var existing = reviewTranslations.FirstOrDefault(t => t.LanguageCode == languageCode);
        if (existing is not null)
        {
            existing.ReplaceText(translatedText, provider);
            return;
        }

        reviewTranslations.Add(new ReviewTranslation(Id, languageCode, translatedText, provider));
    }

    private static void ValidateOptionalScore(byte? value, string paramName)
    {
        if (value is null)
            return;

        if (value is < 1 or > 5)
            throw new ArgumentOutOfRangeException(paramName);
    }
}
