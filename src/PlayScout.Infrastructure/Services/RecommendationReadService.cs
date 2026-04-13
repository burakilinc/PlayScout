namespace PlayScout.Infrastructure.Services;

using PlayScout.Application.Abstractions;
using PlayScout.Application.Contracts;

public sealed class RecommendationReadService : IRecommendationReadService
{
    private readonly IVenueReadService _venueReadService;

    public RecommendationReadService(IVenueReadService venueReadService) =>
        _venueReadService = venueReadService;

    public async Task<RecommendationResponse> GetAsync(
        RecommendationRequest request,
        CancellationToken cancellationToken = default)
    {
        var nearby = await _venueReadService.GetNearbyAsync(
            new VenueNearbyRequest(
                request.Latitude,
                request.Longitude,
                request.RadiusMeters ?? 3000,
                request.ChildAgeMonths,
                request.RequirePlaySupervisor,
                request.RequireChildDropOff,
                request.FeatureTypes,
                request.MaxResults ?? 20),
            cancellationToken);

        return new RecommendationResponse(nearby.Items);
    }
}
