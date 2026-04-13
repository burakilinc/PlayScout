namespace PlayScout.Domain.Venues;

using PlayScout.Domain.Common;

public sealed class VenueFeature : Entity
{
    public Guid VenueId { get; private init; }

    public VenueFeatureType Type { get; private init; }

    public VenueFeature(Guid venueId, VenueFeatureType type)
    {
        VenueId = venueId;
        Type = type;
    }

    private VenueFeature()
    {
    }
}
