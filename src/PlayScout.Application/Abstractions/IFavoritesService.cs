namespace PlayScout.Application.Abstractions;

using PlayScout.Application.Contracts;

public interface IFavoritesService
{
    Task<(bool Success, AddFavoriteResponse? Response, string? Error)> AddAsync(
        Guid userId,
        Guid venueId,
        CancellationToken cancellationToken = default);

    Task<(bool Deleted, string? Error)> RemoveAsync(
        Guid userId,
        Guid venueId,
        CancellationToken cancellationToken = default);

    Task<IReadOnlyList<FavoriteListItemDto>> ListAsync(
        Guid userId,
        double? latitude,
        double? longitude,
        CancellationToken cancellationToken = default);
}
