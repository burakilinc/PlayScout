namespace PlayScout.Domain.Venues;

using PlayScout.Domain.Common;

public sealed class VenueImage : Entity
{
    public Guid VenueId { get; private init; }

    public string Url { get; private init; }

    public int SortOrder { get; private set; }

    public string? AltText { get; private set; }

    public VenueImage(Guid venueId, string url, int sortOrder, string? altText = null)
    {
        VenueId = venueId;
        Url = url;
        SortOrder = sortOrder;
        AltText = altText;
    }

    private VenueImage()
    {
        Url = null!;
    }
}
