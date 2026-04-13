namespace PlayScout.Domain.Suggestions;

/// <summary>High-level place kind for moderation triage (not the same as per-feature amenities).</summary>
public enum SuggestedPlaceCategory
{
    IndoorPlay = 1,
    OutdoorPlay = 2,
    MixedIndoorOutdoor = 3,
    DropInCare = 4,
    FamilyCafeOrRestaurant = 5,
    Other = 99,
}
