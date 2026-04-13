namespace PlayScout.Application.Ranking;

using PlayScout.Application.Contracts;

/// <summary>
/// Sort order: distance (asc), age suitability, trust signals, rating — per product rules.
/// </summary>
public static class VenueRanking
{
    public static IReadOnlyList<VenueSummaryDto> Sort(IReadOnlyList<VenueSummaryDto> items, int? childAgeMonths) =>
        items
            .OrderBy(x => x.DistanceMeters)
            .ThenByDescending(x => AgeSuitabilityRank(x, childAgeMonths))
            .ThenByDescending(x => TrustRank(x))
            .ThenByDescending(x => x.AverageRating ?? 0d)
            .ToList();

    private static int TrustRank(VenueSummaryDto x) =>
        (x.HasPlaySupervisor ? 2 : 0) + (x.AllowsChildDropOff ? 1 : 0);

    private static int AgeSuitabilityRank(VenueSummaryDto x, int? childAgeMonths)
    {
        if (!childAgeMonths.HasValue)
            return 0;

        var c = childAgeMonths.Value;
        var min = x.MinAgeMonths;
        var max = x.MaxAgeMonths;

        if (min is null && max is null)
            return 1;

        if (min.HasValue && c < min.Value)
            return -1;

        if (max.HasValue && c > max.Value)
            return -1;

        return 2;
    }
}
