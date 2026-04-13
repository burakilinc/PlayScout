namespace PlayScout.Domain.Events;

using PlayScout.Domain.Common;

/// <summary>
/// Scheduled occurrence (festival, open day, seasonal activity). May be tied to a venue or city-wide.
/// </summary>
public sealed class Event : Entity
{
    public Guid? VenueId { get; private set; }

    public string Title { get; private set; }

    public string? Description { get; private set; }

    public DateTimeOffset StartsAt { get; private set; }

    public DateTimeOffset EndsAt { get; private set; }

    public string? ExternalUrl { get; private set; }

    /// <summary>When <see cref="VenueId"/> is null, human-readable location for Event Detail (e.g. neighborhood, park name).</summary>
    public string? LocationLabel { get; private set; }

    public int? MinAgeMonths { get; private set; }

    public int? MaxAgeMonths { get; private set; }

    public Event(
        string title,
        DateTimeOffset startsAt,
        DateTimeOffset endsAt,
        Guid? venueId = null,
        string? description = null,
        string? externalUrl = null,
        string? locationLabel = null,
        int? minAgeMonths = null,
        int? maxAgeMonths = null)
    {
        Title = title;
        StartsAt = startsAt;
        EndsAt = endsAt;
        VenueId = venueId;
        Description = description;
        ExternalUrl = externalUrl;
        LocationLabel = locationLabel;
        MinAgeMonths = minAgeMonths;
        MaxAgeMonths = maxAgeMonths;
    }

    private Event()
    {
        Title = null!;
    }
}
