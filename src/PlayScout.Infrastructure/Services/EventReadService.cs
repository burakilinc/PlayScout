namespace PlayScout.Infrastructure.Services;

using Microsoft.EntityFrameworkCore;
using PlayScout.Application.Abstractions;
using PlayScout.Application.Contracts;
using PlayScout.Infrastructure.Persistence;

public sealed class EventReadService : IEventReadService
{
    private readonly PlayScoutDbContext _db;

    public EventReadService(PlayScoutDbContext db) => _db = db;

    public async Task<EventListResponse> ListAsync(
        EventListRequest request,
        CancellationToken cancellationToken = default)
    {
        var page = Math.Max(1, request.Page ?? 1);
        var pageSize = Math.Clamp(request.PageSize ?? 50, 1, 100);
        var fromUtc = request.FromUtc ?? DateTimeOffset.UtcNow.AddHours(-6);
        var toUtc = request.ToUtc ?? DateTimeOffset.UtcNow.AddDays(120);

        var query =
            from e in _db.Events.AsNoTracking()
            join v in _db.Venues.AsNoTracking() on e.VenueId equals v.Id into vg
            from v in vg.DefaultIfEmpty()
            where e.EndsAt >= fromUtc && e.StartsAt <= toUtc
            select new { e, v };

        if (request.VenueId is { } venueId)
            query = query.Where(x => x.e.VenueId == venueId);

        var total = await query.CountAsync(cancellationToken);

        var items = await query
            .OrderBy(x => x.e.StartsAt)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(x => new EventListItemDto(
                x.e.Id,
                x.e.Title,
                x.e.StartsAt,
                x.e.EndsAt,
                x.e.VenueId,
                x.v != null ? x.v.Name : null,
                x.e.MinAgeMonths,
                x.e.MaxAgeMonths,
                x.v != null ? x.v.Name : x.e.LocationLabel))
            .ToListAsync(cancellationToken);

        return new EventListResponse(items, page, pageSize, total);
    }

    public async Task<EventDetailDto?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var row = await (
            from e in _db.Events.AsNoTracking()
            join v in _db.Venues.AsNoTracking() on e.VenueId equals v.Id into vg
            from v in vg.DefaultIfEmpty()
            where e.Id == id
            select new
            {
                e.Id,
                e.Title,
                e.StartsAt,
                e.EndsAt,
                e.MinAgeMonths,
                e.MaxAgeMonths,
                e.Description,
                e.ExternalUrl,
                e.VenueId,
                VenueName = v != null ? v.Name : null,
                VenueLat = v != null ? (double?)v.Latitude : null,
                VenueLon = v != null ? (double?)v.Longitude : null,
                e.LocationLabel,
            }).FirstOrDefaultAsync(cancellationToken);

        if (row is null)
            return null;

        var location = new EventLocationDto(
            row.VenueId,
            row.VenueName,
            row.VenueLat,
            row.VenueLon,
            row.LocationLabel);

        return new EventDetailDto(
            row.Id,
            row.Title,
            row.StartsAt,
            row.EndsAt,
            row.MinAgeMonths,
            row.MaxAgeMonths,
            row.Description,
            location,
            row.ExternalUrl);
    }
}
