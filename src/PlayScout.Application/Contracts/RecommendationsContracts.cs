namespace PlayScout.Application.Contracts;

/// <summary>GET /recommendations — same filters as nearby with tuned defaults for “decide now”.</summary>
public sealed record RecommendationRequest(
    double Latitude,
    double Longitude,
    int? RadiusMeters = 3000,
    int? ChildAgeMonths = null,
    bool? RequirePlaySupervisor = null,
    bool? RequireChildDropOff = null,
    int[]? FeatureTypes = null,
    int? MaxResults = 20);

public sealed record RecommendationResponse(IReadOnlyList<VenueSummaryDto> Items);
