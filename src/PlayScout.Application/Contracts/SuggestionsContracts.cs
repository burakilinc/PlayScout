namespace PlayScout.Application.Contracts;

using PlayScout.Domain.Moderation;
using PlayScout.Domain.Suggestions;
using PlayScout.Domain.Venues;

public sealed record CreateSuggestionRequest(
    string Name,
    SuggestedPlaceCategory Category,
    double? Latitude,
    double? Longitude,
    string? LocationLabel,
    string? Description,
    int? MinAgeMonths,
    int? MaxAgeMonths,
    bool HasPlaySupervisor,
    bool AllowsChildDropOff,
    IReadOnlyList<VenueFeatureType>? OptionalAmenities);

/// <summary>POST /suggestions — confirmation payload for the client “thanks” screen.</summary>
public sealed record CreateSuggestionResponse(
    Guid SuggestionId,
    string Name,
    SuggestedPlaceCategory Category,
    ModerationStatus ModerationStatus,
    string ModerationStatusKey,
    string ConfirmationTitle,
    string ConfirmationMessage,
    DateTimeOffset CreatedAtUtc);
