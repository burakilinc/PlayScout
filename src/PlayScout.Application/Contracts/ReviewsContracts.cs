namespace PlayScout.Application.Contracts;

public sealed record CreateReviewRequest(
    Guid VenueId,
    int Rating,
    string Comment,
    /// <summary>Required normalized language of <see cref="Comment"/> (primary subtag, e.g. en).</summary>
    string OriginalLanguage,
    byte? CleanlinessScore = null,
    byte? SafetyScore = null,
    byte? SuitabilityForSmallChildrenScore = null);

public sealed record CreateReviewResponse(Guid ReviewId);

public sealed record ReviewsListQuery(Guid VenueId, string? Language);

public sealed record ReviewsForVenueResponse(IReadOnlyList<ReviewCardDto> Items);

public sealed record StructuredScoresDto(
    byte? Cleanliness,
    byte? Safety,
    byte? SuitabilityForSmallChildren);

/// <summary>Metadata for clients that may hide or collapse the original body when showing a translation.</summary>
public sealed record OriginalTextAvailabilityDto(
    bool IsIncludedInResponse,
    int CharacterCount,
    string Language);

/// <summary>Review list item optimized for mobile review cards.</summary>
public sealed record ReviewCardDto(
    Guid Id,
    Guid VenueId,
    string AuthorDisplayName,
    int Rating,
    StructuredScoresDto? StructuredScores,
    string OriginalLanguage,
    string RequestedLanguage,
    bool IsTranslated,
    string? TranslatedFromLanguage,
    string DisplayText,
    string OriginalText,
    OriginalTextAvailabilityDto OriginalTextAvailability,
    DateTimeOffset CreatedAtUtc);
