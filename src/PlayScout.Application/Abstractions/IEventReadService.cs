namespace PlayScout.Application.Abstractions;

using PlayScout.Application.Contracts;

public interface IEventReadService
{
    Task<EventListResponse> ListAsync(EventListRequest request, CancellationToken cancellationToken = default);

    Task<EventDetailDto?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
}
