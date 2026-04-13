namespace PlayScout.Application.Contracts;

/// <summary>GET /events — list and filters.</summary>
public sealed record EventListRequest(
    DateTimeOffset? FromUtc = null,
    DateTimeOffset? ToUtc = null,
    Guid? VenueId = null,
    int? Page = 1,
    int? PageSize = 50);

public sealed record EventListResponse(
    IReadOnlyList<EventListItemDto> Items,
    int Page,
    int PageSize,
    int TotalCount);

public sealed record EventListItemDto(
    Guid Id,
    string Title,
    DateTimeOffset StartsAt,
    DateTimeOffset EndsAt,
    Guid? VenueId,
    string? VenueName,
    int? MinAgeMonths,
    int? MaxAgeMonths,
    string? LocationSummary);

/// <summary>GET /events/{id} — Event Detail (no Stitch screen; fields align with product spec).</summary>
public sealed record EventDetailDto(
    Guid Id,
    string Title,
    DateTimeOffset StartsAt,
    DateTimeOffset EndsAt,
    int? MinAgeMonths,
    int? MaxAgeMonths,
    string? Description,
    EventLocationDto Location,
    string? ExternalUrl);

public sealed record EventLocationDto(
    Guid? VenueId,
    string? VenueName,
    double? VenueLatitude,
    double? VenueLongitude,
    string? LocationLabel);
