namespace PlayScout.Infrastructure.Services;

using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using PlayScout.Application.Abstractions;
using PlayScout.Application.Contracts;
using PlayScout.Domain.Moderation;
using PlayScout.Domain.Suggestions;
using PlayScout.Domain.Venues;
using PlayScout.Infrastructure.Persistence;

public sealed class SuggestionsService : ISuggestionsService
{
    private static readonly JsonSerializerOptions JsonOptions = new() { PropertyNamingPolicy = JsonNamingPolicy.CamelCase };

    private readonly PlayScoutDbContext _db;

    public SuggestionsService(PlayScoutDbContext db) => _db = db;

    public async Task<(bool ok, CreateSuggestionResponse? response, string? error)> CreateAsync(
        Guid userId,
        CreateSuggestionRequest request,
        CancellationToken cancellationToken)
    {
        var userExists = await _db.Users.AsNoTracking().AnyAsync(u => u.Id == userId, cancellationToken);
        if (!userExists)
            return (false, null, "user_not_found");

        var amenitiesJson = SerializeAmenities(request.OptionalAmenities);

        var entity = new SuggestedVenue(
            submittedByUserId: userId,
            name: request.Name.Trim(),
            category: request.Category,
            latitude: request.Latitude,
            longitude: request.Longitude,
            locationLabel: request.LocationLabel?.Trim(),
            hasPlaySupervisor: request.HasPlaySupervisor,
            allowsChildDropOff: request.AllowsChildDropOff,
            description: request.Description?.Trim(),
            minAgeMonths: request.MinAgeMonths,
            maxAgeMonths: request.MaxAgeMonths,
            amenitiesJson: amenitiesJson);

        _db.SuggestedVenues.Add(entity);
        await _db.SaveChangesAsync(cancellationToken);

        var response = new CreateSuggestionResponse(
            SuggestionId: entity.Id,
            Name: entity.Name,
            Category: entity.Category,
            ModerationStatus: entity.Status,
            ModerationStatusKey: ToStatusKey(entity.Status),
            ConfirmationTitle: "Thanks for helping PlayScout grow!",
            ConfirmationMessage:
                "We received your place suggestion. Our team will review it soon — you will see it in the app if it is approved.",
            CreatedAtUtc: entity.CreatedAt);

        return (true, response, null);
    }

    private static string ToStatusKey(ModerationStatus status) =>
        status switch
        {
            ModerationStatus.Pending => "pending",
            ModerationStatus.Approved => "approved",
            ModerationStatus.Rejected => "rejected",
            ModerationStatus.NeedsChanges => "needs_changes",
            _ => "unknown",
        };

    private static string? SerializeAmenities(IReadOnlyList<VenueFeatureType>? list)
    {
        if (list is null || list.Count == 0)
            return null;

        var ids = list.Distinct().Select(t => (int)t).OrderBy(x => x).ToArray();
        return JsonSerializer.Serialize(ids, JsonOptions);
    }
}
