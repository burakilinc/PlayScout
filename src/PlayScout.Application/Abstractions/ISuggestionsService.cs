namespace PlayScout.Application.Abstractions;

using PlayScout.Application.Contracts;

public interface ISuggestionsService
{
    Task<(bool ok, CreateSuggestionResponse? response, string? error)> CreateAsync(
        Guid userId,
        CreateSuggestionRequest request,
        CancellationToken cancellationToken);
}
