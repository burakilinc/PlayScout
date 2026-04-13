import 'package:flutter/material.dart';
import 'package:playscout_app/l10n/app_localizations.dart';

import '../../../design_system/design_tokens.dart';
import '../../home_discover/models/venue_summary.dart';
import '../logic/search_venue_query.dart';

class SearchResultVenueCard extends StatelessWidget {
  const SearchResultVenueCard({
    super.key,
    required this.venue,
    required this.onTap,
    required this.isFavorite,
    required this.onFavoriteTap,
  });

  final VenueSummary venue;
  final VoidCallback onTap;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final rating = venue.averageRating;
    final ratingLabel = rating == null ? l10n.dashEmDash : rating.toStringAsFixed(1);
    return Material(
      color: PsColors.surfaceContainerLowest,
      elevation: 0,
      borderRadius: BorderRadius.circular(PsRadii.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(PsRadii.md),
        child: Padding(
          padding: const EdgeInsets.all(PsSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      venue.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: PsColors.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: PsSpacing.xs),
                    Row(
                      children: [
                        Icon(Icons.star_rounded, size: 18, color: PsColors.tertiary),
                        const SizedBox(width: 4),
                        Text(
                          ratingLabel,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: PsColors.onSurface,
                          ),
                        ),
                        const SizedBox(width: PsSpacing.md),
                        Icon(Icons.near_me_outlined, size: 16, color: PsColors.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          formatSearchDistanceMeters(l10n, venue.distanceMeters),
                          style: theme.textTheme.bodySmall?.copyWith(color: PsColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                    const SizedBox(height: PsSpacing.xs),
                    Text(
                      formatSearchAgeRange(l10n, venue),
                      style: theme.textTheme.bodySmall?.copyWith(color: PsColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: PsSpacing.sm),
              IconButton(
                onPressed: onFavoriteTap,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                icon: Icon(
                  isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: isFavorite ? PsColors.error : PsColors.onSurfaceVariant.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
