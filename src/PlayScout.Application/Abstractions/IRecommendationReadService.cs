namespace PlayScout.Application.Abstractions;

using PlayScout.Application.Contracts;

public interface IRecommendationReadService
{
    Task<RecommendationResponse> GetAsync(RecommendationRequest request, CancellationToken cancellationToken = default);
}
