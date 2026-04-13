namespace PlayScout.Domain.Favorites;

using PlayScout.Domain.Common;

public sealed class Favorite : Entity
{
    public Guid UserId { get; private init; }

    public Guid VenueId { get; private init; }

    public Favorite(Guid userId, Guid venueId)
    {
        UserId = userId;
        VenueId = venueId;
    }

    private Favorite()
    {
    }
}
