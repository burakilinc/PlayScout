namespace PlayScout.Infrastructure.Persistence;

using Microsoft.EntityFrameworkCore;
using PlayScout.Domain.Events;
using PlayScout.Domain.Venues;

public static class PlayScoutDbSeeder
{
    /// <summary>Idempotent seed for local / first-run environments.</summary>
    public static async Task SeedDevelopmentDataAsync(PlayScoutDbContext db, CancellationToken cancellationToken = default)
    {
        if (await db.Venues.AnyAsync(cancellationToken))
            return;

        var v1 = new Venue(
            name: "Little Explorers Hub",
            latitude: 41.0082,
            longitude: 28.9784,
            hasPlaySupervisor: true,
            allowsChildDropOff: true,
            minAgeMonths: 0,
            maxAgeMonths: 60,
            description: "Indoor play with supervised sessions.");
        v1.UpsertFeature(VenueFeatureType.Indoor, true);
        v1.UpsertFeature(VenueFeatureType.Shade, false);
        v1.AddImage("https://example.com/playscout/venue1.jpg", 0, "Indoor play area");

        var v2 = new Venue(
            name: "Riverside Play Park",
            latitude: 41.0120,
            longitude: 28.9850,
            hasPlaySupervisor: false,
            allowsChildDropOff: false,
            minAgeMonths: 24,
            maxAgeMonths: 120,
            description: "Fenced outdoor park.");
        v2.UpsertFeature(VenueFeatureType.Outdoor, true);
        v2.UpsertFeature(VenueFeatureType.Fenced, true);
        v2.AddImage("https://example.com/playscout/venue2.jpg", 0, "Outdoor playground");

        var v3 = new Venue(
            name: "Drop & Play Studio",
            latitude: 41.0055,
            longitude: 28.9720,
            hasPlaySupervisor: true,
            allowsChildDropOff: true,
            minAgeMonths: 12,
            maxAgeMonths: 72,
            description: "Short-stay drop-off with registered staff.");
        v3.UpsertFeature(VenueFeatureType.Indoor, true);
        v3.AddImage("https://example.com/playscout/venue3.jpg", 0, "Studio entrance");

        db.Venues.AddRange(v1, v2, v3);
        await db.SaveChangesAsync(cancellationToken);

        var e1 = new Event(
            title: "Messy Art Morning",
            startsAt: DateTimeOffset.UtcNow.AddDays(2).Date.AddHours(10),
            endsAt: DateTimeOffset.UtcNow.AddDays(2).Date.AddHours(12),
            venueId: v1.Id,
            description: "Outdoor-friendly art session for toddlers.",
            locationLabel: null,
            minAgeMonths: 18,
            maxAgeMonths: 48);

        var e2 = new Event(
            title: "Neighborhood Play Meetup",
            startsAt: DateTimeOffset.UtcNow.AddDays(5).Date.AddHours(15),
            endsAt: DateTimeOffset.UtcNow.AddDays(5).Date.AddHours(17),
            venueId: null,
            description: "Parent-led meetup at the central meadow.",
            locationLabel: "Golden Horn Meadow",
            minAgeMonths: 0,
            maxAgeMonths: 84);

        db.Events.AddRange(e1, e2);
        await db.SaveChangesAsync(cancellationToken);
    }
}
