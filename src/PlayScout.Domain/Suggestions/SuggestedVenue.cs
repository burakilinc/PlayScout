namespace PlayScout.Domain.Suggestions;

using PlayScout.Domain.Common;
using PlayScout.Domain.Moderation;

/// <summary>
/// User-submitted place candidate. Stays pending until moderation and is never auto-promoted to a live venue.
/// </summary>
public sealed class SuggestedVenue : Entity
{
    public Guid? SubmittedByUserId { get; private init; }

    public string Name { get; private set; }

    public SuggestedPlaceCategory Category { get; private set; }

    public string? Description { get; private set; }

    public double? Latitude { get; private set; }

    public double? Longitude { get; private set; }

    /// <summary>Free-text address or “near X” label when coordinates are unknown or supplementary.</summary>
    public string? LocationLabel { get; private set; }

    public int? MinAgeMonths { get; private set; }

    public int? MaxAgeMonths { get; private set; }

    public bool HasPlaySupervisor { get; private set; }

    public bool AllowsChildDropOff { get; private set; }

    /// <summary>JSON array of <c>int</c> values for <see cref="Venues.VenueFeatureType"/> (non-trust amenities only).</summary>
    public string? AmenitiesJson { get; private set; }

    public ModerationStatus Status { get; private set; }

    public string? ModeratorNotes { get; private set; }

    public SuggestedVenue(
        Guid submittedByUserId,
        string name,
        SuggestedPlaceCategory category,
        double? latitude,
        double? longitude,
        string? locationLabel,
        bool hasPlaySupervisor,
        bool allowsChildDropOff,
        string? description = null,
        int? minAgeMonths = null,
        int? maxAgeMonths = null,
        string? amenitiesJson = null)
    {
        if (string.IsNullOrWhiteSpace(name))
            throw new ArgumentException("Name is required.", nameof(name));

        SubmittedByUserId = submittedByUserId;
        Name = name.Trim();
        Category = category;
        Latitude = latitude;
        Longitude = longitude;
        LocationLabel = string.IsNullOrWhiteSpace(locationLabel) ? null : locationLabel.Trim();
        HasPlaySupervisor = hasPlaySupervisor;
        AllowsChildDropOff = allowsChildDropOff;
        Description = string.IsNullOrWhiteSpace(description) ? null : description.Trim();
        MinAgeMonths = minAgeMonths;
        MaxAgeMonths = maxAgeMonths;
        AmenitiesJson = string.IsNullOrWhiteSpace(amenitiesJson) ? null : amenitiesJson.Trim();
        Status = ModerationStatus.Pending;
    }

    private SuggestedVenue()
    {
        Name = null!;
    }

    public void SetModeration(ModerationStatus status, string? moderatorNotes = null)
    {
        Status = status;
        ModeratorNotes = moderatorNotes;
        UpdatedAt = DateTimeOffset.UtcNow;
    }
}
