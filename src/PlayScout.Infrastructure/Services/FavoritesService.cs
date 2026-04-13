namespace PlayScout.Infrastructure.Services;

using Microsoft.EntityFrameworkCore;
using PlayScout.Application.Abstractions;
using PlayScout.Application.Contracts;
using PlayScout.Domain.Favorites;
using PlayScout.Infrastructure.Geo;
using PlayScout.Infrastructure.Persistence;

public sealed class FavoritesService : IFavoritesService
{
    private readonly PlayScoutDbContext _db;

    public FavoritesService(PlayScoutDbContext db) => _db = db;

    public async Task<(bool Success, AddFavoriteResponse? Response, string? Error)> AddAsync(
        Guid userId,
        Guid venueId,
        CancellationToken cancellationToken = default)
    {
        if (!await _db.Venues.AsNoTracking().AnyAsync(v => v.Id == venueId, cancellationToken))
            return (false, null, "venue_not_found");

        var existing = await _db.Favorites.AsNoTracking()
            .FirstOrDefaultAsync(f => f.UserId == userId && f.VenueId == venueId, cancellationToken);

        if (existing is not null)
        {
            return (true, new AddFavoriteResponse(existing.Id, venueId, WasAlreadyFavorite: true), null);
        }

        await using var tx =
            await _db.Database.BeginTransactionAsync(System.Data.IsolationLevel.Serializable, cancellationToken);

        var duplicate = await _db.Favorites
            .FirstOrDefaultAsync(f => f.UserId == userId && f.VenueId == venueId, cancellationToken);

        if (duplicate is not null)
        {
            await tx.CommitAsync(cancellationToken);
            return (true, new AddFavoriteResponse(duplicate.Id, venueId, WasAlreadyFavorite: true), null);
        }

        var favorite = new Favorite(userId, venueId);
        _db.Favorites.Add(favorite);

        try
        {
            await _db.SaveChangesAsync(cancellationToken);
            await tx.CommitAsync(cancellationToken);
        }
        catch (DbUpdateException)
        {
            await tx.RollbackAsync(cancellationToken);
            var afterRace = await _db.Favorites.AsNoTracking()
                .FirstOrDefaultAsync(f => f.UserId == userId && f.VenueId == venueId, cancellationToken);
            if (afterRace is null)
                throw;

            return (true, new AddFavoriteResponse(afterRace.Id, venueId, WasAlreadyFavorite: true), null);
        }

        return (true, new AddFavoriteResponse(favorite.Id, venueId, WasAlreadyFavorite: false), null);
    }

    public async Task<(bool Deleted, string? Error)> RemoveAsync(
        Guid userId,
        Guid venueId,
        CancellationToken cancellationToken = default)
    {
        var favorite = await _db.Favorites
            .FirstOrDefaultAsync(f => f.UserId == userId && f.VenueId == venueId, cancellationToken);

        if (favorite is null)
            return (false, "favorite_not_found");

        _db.Favorites.Remove(favorite);
        await _db.SaveChangesAsync(cancellationToken);
        return (true, null);
    }

    public async Task<IReadOnlyList<FavoriteListItemDto>> ListAsync(
        Guid userId,
        double? latitude,
        double? longitude,
        CancellationToken cancellationToken = default)
    {
        var query =
            from f in _db.Favorites.AsNoTracking()
            join v in _db.Venues.AsNoTracking() on f.VenueId equals v.Id
            where f.UserId == userId
            orderby f.CreatedAt descending
            select new { f, v };

        var rows = await query.ToListAsync(cancellationToken);
        if (rows.Count == 0)
            return Array.Empty<FavoriteListItemDto>();

        var venueIds = rows.Select(x => x.v.Id).Distinct().ToList();
        var primaryByVenue = await LoadPrimaryImagesAsync(venueIds, cancellationToken);

        var hasCoords = latitude is not null && longitude is not null;

        return rows
            .Select(x =>
            {
                double? distance = null;
                if (hasCoords)
                {
                    distance = GeoMath.HaversineMeters(
                        latitude!.Value,
                        longitude!.Value,
                        x.v.Latitude,
                        x.v.Longitude);
                }

                primaryByVenue.TryGetValue(x.v.Id, out var imgUrl);

                return new FavoriteListItemDto(
                    x.f.Id,
                    x.v.Id,
                    x.v.Name,
                    imgUrl,
                    distance,
                    x.v.AverageRating,
                    x.v.ReviewCount,
                    x.v.MinAgeMonths,
                    x.v.MaxAgeMonths,
                    x.v.HasPlaySupervisor,
                    x.v.AllowsChildDropOff,
                    x.f.CreatedAt);
            })
            .ToList();
    }

    private async Task<Dictionary<Guid, string?>> LoadPrimaryImagesAsync(
        List<Guid> venueIds,
        CancellationToken cancellationToken)
    {
        var images = await _db.VenueImages.AsNoTracking()
            .Where(i => venueIds.Contains(i.VenueId))
            .OrderBy(i => i.VenueId)
            .ThenBy(i => i.SortOrder)
            .Select(i => new { i.VenueId, i.Url })
            .ToListAsync(cancellationToken);

        return images
            .GroupBy(x => x.VenueId)
            .ToDictionary(g => g.Key, g => g.Select(x => x.Url).FirstOrDefault());
    }
}
