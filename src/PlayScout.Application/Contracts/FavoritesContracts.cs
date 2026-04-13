namespace PlayScout.Application.Contracts;

/// <summary>POST /favorites body.</summary>
public sealed record AddFavoriteRequest(Guid VenueId);

/// <summary>POST /favorites response (idempotent: duplicate returns same shape with <see cref="WasAlreadyFavorite"/> true).</summary>
public sealed record AddFavoriteResponse(Guid FavoriteId, Guid VenueId, bool WasAlreadyFavorite);

/// <summary>GET /favorites optional query for distance (Haversine, meters).</summary>
public sealed record FavoriteListQuery(double? Latitude = null, double? Longitude = null);

public sealed record FavoritesListResponse(IReadOnlyList<FavoriteListItemDto> Items);

/// <summary>Payload for Favorites screen + map/list reuse.</summary>
public sealed record FavoriteListItemDto(
    Guid FavoriteId,
    Guid VenueId,
    string VenueName,
    string? PrimaryImageUrl,
    double? DistanceMeters,
    double? AverageRating,
    int ReviewCount,
    int? MinAgeMonths,
    int? MaxAgeMonths,
    bool HasPlaySupervisor,
    bool AllowsChildDropOff,
    DateTimeOffset FavoritedAtUtc);
