namespace PlayScout.Application.Abstractions;

using PlayScout.Application.Contracts;

public interface IReviewsService
{
    Task<(bool ok, CreateReviewResponse? response, string? error)> CreateAsync(
        Guid userId,
        CreateReviewRequest request,
        CancellationToken cancellationToken);

    Task<(bool ok, ReviewsForVenueResponse? response, string? error)> ListForVenueAsync(
        Guid venueId,
        string requestedLanguageNormalized,
        CancellationToken cancellationToken);
}
