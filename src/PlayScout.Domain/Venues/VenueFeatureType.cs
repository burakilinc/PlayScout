namespace PlayScout.Domain.Venues;

/// <summary>
/// Filterable / displayable venue capabilities. Trust-critical flags are also denormalized on <see cref="Venue"/> for ranking queries.
/// </summary>
public enum VenueFeatureType
{
    PlaySupervisorAvailable = 1,
    ChildDropOffAllowed = 2,
    Indoor = 3,
    Outdoor = 4,
    Fenced = 5,
    Shade = 6,
    Sand = 7,
    StrollerFriendly = 8,
    Parking = 9,
    Restrooms = 10,
    FoodNearby = 11,
}
