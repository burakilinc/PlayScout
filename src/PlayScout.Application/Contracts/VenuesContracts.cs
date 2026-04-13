namespace PlayScout.Application.Contracts;

/// <summary>GET /venues/nearby — query string parameters.</summary>
public sealed record VenueNearbyRequest(
    double Latitude,
    double Longitude,
    int? RadiusMeters = 5000,
    int? ChildAgeMonths = null,
    bool? RequirePlaySupervisor = null,
    bool? RequireChildDropOff = null,
    int[]? FeatureTypes = null,
    int? MaxResults = 50);

public sealed record VenueNearbyResponse(IReadOnlyList<VenueSummaryDto> Items);

public sealed record VenueSummaryDto(
    Guid Id,
    string Name,
    double Latitude,
    double Longitude,
    double DistanceMeters,
    bool HasPlaySupervisor,
    bool AllowsChildDropOff,
    int? MinAgeMonths,
    int? MaxAgeMonths,
    double? AverageRating,
    int ReviewCount,
    IReadOnlyList<int> FeatureTypes,
    string? PrimaryImageUrl);

/// <summary>GET /venues/{id}</summary>
public sealed record VenueDetailDto(
    Guid Id,
    string Name,
    string? Description,
    double Latitude,
    double Longitude,
    bool HasPlaySupervisor,
    bool AllowsChildDropOff,
    int? MinAgeMonths,
    int? MaxAgeMonths,
    double? AverageRating,
    int ReviewCount,
    IReadOnlyList<VenueFeatureDto> Features,
    IReadOnlyList<VenueImageDto> Images);

public sealed record VenueFeatureDto(int Type);

public sealed record VenueImageDto(Guid Id, string Url, int SortOrder, string? AltText);
