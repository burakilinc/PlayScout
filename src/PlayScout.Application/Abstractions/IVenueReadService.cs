namespace PlayScout.Application.Abstractions;

using PlayScout.Application.Contracts;

public interface IVenueReadService
{
    Task<VenueNearbyResponse> GetNearbyAsync(VenueNearbyRequest request, CancellationToken cancellationToken = default);

    Task<VenueDetailDto?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
}
