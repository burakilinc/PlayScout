namespace PlayScout.Infrastructure.Services;

using Microsoft.EntityFrameworkCore;
using PlayScout.Application.Abstractions;
using PlayScout.Application.Contracts;
using PlayScout.Application.Ranking;
using PlayScout.Domain.Venues;
using PlayScout.Infrastructure.Geo;
using PlayScout.Infrastructure.Persistence;

public sealed class VenueReadService : IVenueReadService
{
    private const int CandidateCap = 500;

    private readonly PlayScoutDbContext _db;

    public VenueReadService(PlayScoutDbContext db) => _db = db;

    public async Task<VenueNearbyResponse> GetNearbyAsync(
        VenueNearbyRequest request,
        CancellationToken cancellationToken = default)
    {
        var radiusMeters = Math.Clamp(request.RadiusMeters ?? 5000, 100, 50_000);
        var maxResults = Math.Clamp(request.MaxResults ?? 50, 1, 100);

        var (minLat, maxLat, minLon, maxLon) =
            GeoMath.BoundingBoxDegrees(request.Latitude, request.Longitude, radiusMeters);

        IQueryable<Venue> query = _db.Venues.AsNoTracking()
            .Where(v => v.Latitude >= minLat && v.Latitude <= maxLat &&
                        v.Longitude >= minLon && v.Longitude <= maxLon);

        if (request.RequirePlaySupervisor == true)
            query = query.Where(v => v.HasPlaySupervisor);

        if (request.RequireChildDropOff == true)
            query = query.Where(v => v.AllowsChildDropOff);

        if (request.FeatureTypes is { Length: > 0 })
        {
            foreach (var typeInt in request.FeatureTypes.Distinct())
            {
                var t = typeInt;
                query = query.Where(v =>
                    _db.VenueFeatures.Any(f => f.VenueId == v.Id && (int)f.Type == t));
            }
        }

        var candidates = await query.Take(CandidateCap).ToListAsync(cancellationToken);

        var rows = candidates
            .Select(v => new
            {
                v.Id,
                v.Name,
                v.Latitude,
                v.Longitude,
                DistanceMeters = GeoMath.HaversineMeters(request.Latitude, request.Longitude, v.Latitude, v.Longitude),
                v.HasPlaySupervisor,
                v.AllowsChildDropOff,
                v.MinAgeMonths,
                v.MaxAgeMonths,
                v.AverageRating,
                v.ReviewCount,
            })
            .Where(r => r.DistanceMeters <= radiusMeters)
            .OrderBy(r => r.DistanceMeters)
            .Take(maxResults * 4)
            .ToList();

        if (rows.Count == 0)
            return new VenueNearbyResponse(Array.Empty<VenueSummaryDto>());

        var ids = rows.Select(r => r.Id).ToList();

        var featureLookup = await BuildFeatureLookupAsync(ids, cancellationToken);
        var primaryImageLookup = await BuildPrimaryImageLookupAsync(ids, cancellationToken);

        var summaries = rows
            .Select(r => new VenueSummaryDto(
                r.Id,
                r.Name,
                r.Latitude,
                r.Longitude,
                r.DistanceMeters,
                r.HasPlaySupervisor,
                r.AllowsChildDropOff,
                r.MinAgeMonths,
                r.MaxAgeMonths,
                r.AverageRating,
                r.ReviewCount,
                featureLookup.GetValueOrDefault(r.Id, Array.Empty<int>()),
                primaryImageLookup.GetValueOrDefault(r.Id)))
            .ToList();

        var ranked = VenueRanking.Sort(summaries, request.ChildAgeMonths).Take(maxResults).ToList();

        return new VenueNearbyResponse(ranked);
    }

    public async Task<VenueDetailDto?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var v = await _db.Venues.AsNoTracking()
            .Include("venueFeatures")
            .Include("venueImages")
            .FirstOrDefaultAsync(x => x.Id == id, cancellationToken);

        if (v is null)
            return null;

        var images = v.Images
            .OrderBy(i => i.SortOrder)
            .Select(i => new VenueImageDto(i.Id, i.Url, i.SortOrder, i.AltText))
            .ToList();

        var features = v.Features
            .Select(f => new VenueFeatureDto((int)f.Type))
            .ToList();

        return new VenueDetailDto(
            v.Id,
            v.Name,
            v.Description,
            v.Latitude,
            v.Longitude,
            v.HasPlaySupervisor,
            v.AllowsChildDropOff,
            v.MinAgeMonths,
            v.MaxAgeMonths,
            v.AverageRating,
            v.ReviewCount,
            features,
            images);
    }

    private async Task<Dictionary<Guid, IReadOnlyList<int>>> BuildFeatureLookupAsync(
        List<Guid> venueIds,
        CancellationToken cancellationToken)
    {
        var rows = await _db.VenueFeatures.AsNoTracking()
            .Where(f => venueIds.Contains(f.VenueId))
            .Select(f => new { f.VenueId, Type = (int)f.Type })
            .ToListAsync(cancellationToken);

        return rows
            .GroupBy(x => x.VenueId)
            .ToDictionary(g => g.Key, g => (IReadOnlyList<int>)g.Select(x => x.Type).Distinct().ToList());
    }

    private async Task<Dictionary<Guid, string?>> BuildPrimaryImageLookupAsync(
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
