namespace PlayScout.Domain.Events;

using PlayScout.Domain.Common;

/// <summary>
/// Structured, bookable learning session at a venue (distinct from general events in product copy).
/// </summary>
public sealed class Workshop : Entity
{
    public Guid VenueId { get; private init; }

    public string Title { get; private set; }

    public string? Description { get; private set; }

    public DateTimeOffset StartsAt { get; private set; }

    public DateTimeOffset EndsAt { get; private set; }

    public int? MinAgeMonths { get; private set; }

    public int? MaxAgeMonths { get; private set; }

    public int? Capacity { get; private set; }

    public Workshop(
        Guid venueId,
        string title,
        DateTimeOffset startsAt,
        DateTimeOffset endsAt,
        int? minAgeMonths = null,
        int? maxAgeMonths = null,
        int? capacity = null,
        string? description = null)
    {
        VenueId = venueId;
        Title = title;
        StartsAt = startsAt;
        EndsAt = endsAt;
        MinAgeMonths = minAgeMonths;
        MaxAgeMonths = maxAgeMonths;
        Capacity = capacity;
        Description = description;
    }

    private Workshop()
    {
        Title = null!;
    }
}
