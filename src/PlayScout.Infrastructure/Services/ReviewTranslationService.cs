namespace PlayScout.Infrastructure.Services;

using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using PlayScout.Application.Abstractions;
using PlayScout.Domain.Reviews;
using PlayScout.Infrastructure.Persistence;

public sealed class ReviewTranslationService : IReviewTranslationService
{
    private readonly PlayScoutDbContext _db;
    private readonly ITranslationProvider _provider;

    public ReviewTranslationService(PlayScoutDbContext db, ITranslationProvider provider)
    {
        _db = db;
        _provider = provider;
    }

    public async Task<ResolvedReviewText> GetDisplayTextAsync(
        Guid venueReviewId,
        string originalText,
        string originalLanguage,
        string requestedLanguage,
        CancellationToken cancellationToken)
    {
        var map = await GetDisplayTextsAsync(
            new[] { new ReviewTranslationSource(venueReviewId, originalText, originalLanguage) },
            requestedLanguage,
            cancellationToken);
        return map[venueReviewId];
    }

    public async Task<IReadOnlyDictionary<Guid, ResolvedReviewText>> GetDisplayTextsAsync(
        IReadOnlyList<ReviewTranslationSource> sources,
        string requestedLanguage,
        CancellationToken cancellationToken)
    {
        var result = new Dictionary<Guid, ResolvedReviewText>(sources.Count);
        var needsCacheOrTranslate = new List<ReviewTranslationSource>();

        foreach (var s in sources)
        {
            if (string.Equals(s.OriginalLanguage, requestedLanguage, StringComparison.OrdinalIgnoreCase))
                result[s.ReviewId] = new ResolvedReviewText(s.OriginalText, false, null);
            else
                needsCacheOrTranslate.Add(s);
        }

        if (needsCacheOrTranslate.Count == 0)
            return result;

        var pendingIds = needsCacheOrTranslate.Select(x => x.ReviewId).Distinct().ToArray();
        var cached = await _db.ReviewTranslations.AsNoTracking()
            .Where(t => pendingIds.Contains(t.VenueReviewId) && t.LanguageCode == requestedLanguage)
            .ToDictionaryAsync(t => t.VenueReviewId, cancellationToken);

        var toTranslate = new List<ReviewTranslationSource>();
        foreach (var s in needsCacheOrTranslate)
        {
            if (result.ContainsKey(s.ReviewId))
                continue;

            if (cached.TryGetValue(s.ReviewId, out var row))
                result[s.ReviewId] = new ResolvedReviewText(row.TranslatedText, true, s.OriginalLanguage);
            else
                toTranslate.Add(s);
        }

        foreach (var s in toTranslate)
        {
            if (result.ContainsKey(s.ReviewId))
                continue;

            var translated = await _provider.TranslateAsync(
                s.OriginalText,
                s.OriginalLanguage,
                requestedLanguage,
                cancellationToken);

            try
            {
                _db.ReviewTranslations.Add(
                    new ReviewTranslation(s.ReviewId, requestedLanguage, translated, _provider.ProviderKey));
                await _db.SaveChangesAsync(cancellationToken);
                result[s.ReviewId] = new ResolvedReviewText(translated, true, s.OriginalLanguage);
            }
            catch (DbUpdateException ex) when (IsUniqueTranslationViolation(ex))
            {
                DetachPendingTranslationAdds();
                var existing = await _db.ReviewTranslations.AsNoTracking()
                    .FirstOrDefaultAsync(
                        t => t.VenueReviewId == s.ReviewId && t.LanguageCode == requestedLanguage,
                        cancellationToken);

                if (existing is not null)
                    result[s.ReviewId] = new ResolvedReviewText(existing.TranslatedText, true, s.OriginalLanguage);
                else
                    result[s.ReviewId] = new ResolvedReviewText(s.OriginalText, false, null);
            }
        }

        return result;
    }

    private static bool IsUniqueTranslationViolation(DbUpdateException ex) =>
        ex.InnerException is SqlException sql && sql.Number is 2601 or 2627;

    private void DetachPendingTranslationAdds()
    {
        foreach (var entry in _db.ChangeTracker.Entries<ReviewTranslation>())
        {
            if (entry.State == EntityState.Added)
                entry.State = EntityState.Detached;
        }
    }
}
