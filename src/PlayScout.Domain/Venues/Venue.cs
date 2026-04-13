namespace PlayScout.Domain.Venues;

using PlayScout.Domain.Common;

public sealed class Venue : Entity
{
    public string Name { get; private set; }

    public string? Description { get; private set; }

    public double Latitude { get; private set; }

    public double Longitude { get; private set; }

    public int? MinAgeMonths { get; private set; }

    public int? MaxAgeMonths { get; private set; }

    /// <summary>Staffed play supervision (first-class trust signal).</summary>
    public bool HasPlaySupervisor { get; private set; }

    /// <summary>Registered drop-off / childcare-style service (first-class trust signal).</summary>
    public bool AllowsChildDropOff { get; private set; }

    public double? AverageRating { get; private set; }

    public int ReviewCount { get; private set; }

    private readonly List<VenueFeature> venueFeatures = new();

    private readonly List<VenueImage> venueImages = new();

    public IReadOnlyCollection<VenueFeature> Features => venueFeatures;

    public IReadOnlyCollection<VenueImage> Images => venueImages;

    public Venue(
        string name,
        double latitude,
        double longitude,
        bool hasPlaySupervisor,
        bool allowsChildDropOff,
        int? minAgeMonths = null,
        int? maxAgeMonths = null,
        string? description = null)
    {
        Name = name;
        Latitude = latitude;
        Longitude = longitude;
        HasPlaySupervisor = hasPlaySupervisor;
        AllowsChildDropOff = allowsChildDropOff;
        MinAgeMonths = minAgeMonths;
        MaxAgeMonths = maxAgeMonths;
        Description = description;
        ReviewCount = 0;
    }

    private Venue()
    {
        Name = null!;
    }

    public void SetTrustFlags(bool hasPlaySupervisor, bool allowsChildDropOff)
    {
        HasPlaySupervisor = hasPlaySupervisor;
        AllowsChildDropOff = allowsChildDropOff;
    }

    public void UpsertFeature(VenueFeatureType type, bool enabled)
    {
        var existing = venueFeatures.FirstOrDefault(f => f.Type == type);
        if (existing is null && enabled)
            venueFeatures.Add(new VenueFeature(Id, type));
        else if (existing is not null && !enabled)
            venueFeatures.Remove(existing);
    }

    public void AddImage(string url, int sortOrder, string? altText = null) =>
        venueImages.Add(new VenueImage(Id, url, sortOrder, altText));

    public void RefreshRating(double averageRating, int reviewCount)
    {
        AverageRating = averageRating;
        ReviewCount = reviewCount;
        UpdatedAt = DateTimeOffset.UtcNow;
    }
}
