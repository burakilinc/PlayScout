namespace PlayScout.Infrastructure.Services;

using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using PlayScout.Application.Abstractions;
using PlayScout.Application.Contracts;
using PlayScout.Application.Localization;
using PlayScout.Domain.Reviews;
using PlayScout.Domain.Users;
using PlayScout.Infrastructure.Persistence;

public sealed class ReviewsService : IReviewsService
{
    private readonly PlayScoutDbContext _db;
    private readonly IReviewTranslationService _translations;

    public ReviewsService(PlayScoutDbContext db, IReviewTranslationService translations)
    {
        _db = db;
        _translations = translations;
    }

    public async Task<(bool ok, CreateReviewResponse? response, string? error)> CreateAsync(
        Guid userId,
        CreateReviewRequest request,
        CancellationToken cancellationToken)
    {
        if (!LanguageCodes.TryNormalize(request.OriginalLanguage, out var origLangNorm)
            || !LanguageCodes.IsSupported(origLangNorm))
            return (false, null, "unsupported_language");

        var venueExists = await _db.Venues.AsNoTracking().AnyAsync(v => v.Id == request.VenueId, cancellationToken);
        if (!venueExists)
            return (false, null, "venue_not_found");

        var duplicate = await _db.VenueReviews.AsNoTracking()
            .AnyAsync(r => r.UserId == userId && r.VenueId == request.VenueId, cancellationToken);
        if (duplicate)
            return (false, null, "review_already_exists");

        var review = new VenueReview(
            request.VenueId,
            userId,
            request.Rating,
            request.Comment.Trim(),
            origLangNorm,
            request.CleanlinessScore,
            request.SafetyScore,
            request.SuitabilityForSmallChildrenScore);

        _db.VenueReviews.Add(review);

        try
        {
            await _db.SaveChangesAsync(cancellationToken);
        }
        catch (DbUpdateException ex) when (IsUniqueUserVenueViolation(ex))
        {
            return (false, null, "review_already_exists");
        }

        return (true, new CreateReviewResponse(review.Id), null);
    }

    public async Task<(bool ok, ReviewsForVenueResponse? response, string? error)> ListForVenueAsync(
        Guid venueId,
        string requestedLanguageNormalized,
        CancellationToken cancellationToken)
    {
        var venueExists = await _db.Venues.AsNoTracking().AnyAsync(v => v.Id == venueId, cancellationToken);
        if (!venueExists)
            return (false, null, "venue_not_found");

        var reviews = await _db.VenueReviews.AsNoTracking()
            .Where(r => r.VenueId == venueId)
            .OrderByDescending(r => r.CreatedAt)
            .ToListAsync(cancellationToken);

        if (reviews.Count == 0)
            return (true, new ReviewsForVenueResponse(Array.Empty<ReviewCardDto>()), null);

        var userIds = reviews.Select(r => r.UserId).Distinct().ToArray();
        var users = await _db.Users.AsNoTracking()
            .Where(u => userIds.Contains(u.Id))
            .ToDictionaryAsync(u => u.Id, cancellationToken);

        var sources = reviews
            .Select(r => new ReviewTranslationSource(r.Id, r.OriginalText, r.OriginalLanguage))
            .ToList();

        var resolved = await _translations.GetDisplayTextsAsync(sources, requestedLanguageNormalized, cancellationToken);

        var items = new List<ReviewCardDto>(reviews.Count);
        foreach (var r in reviews)
        {
            users.TryGetValue(r.UserId, out var user);
            var author = PublicDisplayName(user, r.UserId);
            var text = resolved[r.Id];
            var scores = BuildScores(r);

            items.Add(
                new ReviewCardDto(
                    Id: r.Id,
                    VenueId: r.VenueId,
                    AuthorDisplayName: author,
                    Rating: r.RatingStars,
                    StructuredScores: scores,
                    OriginalLanguage: r.OriginalLanguage,
                    RequestedLanguage: requestedLanguageNormalized,
                    IsTranslated: text.IsTranslated,
                    TranslatedFromLanguage: text.TranslatedFromLanguage,
                    DisplayText: text.DisplayText,
                    OriginalText: r.OriginalText,
                    OriginalTextAvailability: new OriginalTextAvailabilityDto(
                        IsIncludedInResponse: true,
                        CharacterCount: r.OriginalText.Length,
                        Language: r.OriginalLanguage),
                    CreatedAtUtc: r.CreatedAt));
        }

        return (true, new ReviewsForVenueResponse(items), null);
    }

    private static StructuredScoresDto? BuildScores(VenueReview r)
    {
        if (r.CleanlinessScore is null && r.SafetyScore is null && r.SuitabilitySmallChildrenScore is null)
            return null;

        return new StructuredScoresDto(r.CleanlinessScore, r.SafetyScore, r.SuitabilitySmallChildrenScore);
    }

    private static string PublicDisplayName(User? user, Guid userId)
    {
        if (user is not null && !string.IsNullOrWhiteSpace(user.DisplayName))
            return user.DisplayName.Trim();

        return $"Member{userId.ToString("N")[..4]}";
    }

    private static bool IsUniqueUserVenueViolation(DbUpdateException ex) =>
        ex.InnerException is SqlException sql && sql.Number is 2601 or 2627;
}
