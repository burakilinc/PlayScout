import 'package:flutter/material.dart';
import 'package:playscout_app/l10n/app_localizations.dart';

import '../../../design_system/design_tokens.dart';
import '../models/venue_summary.dart';
import '../venue_formatters.dart';

String _featureChipLabel(AppLocalizations l10n, int id) {
  return switch (id) {
    1 => l10n.playSupervisorShort,
    2 => l10n.dropoffAllowed,
    3 => l10n.indoor,
    4 => l10n.outdoor,
    5 => l10n.fenced,
    6 => l10n.shade,
    7 => l10n.sand,
    8 => l10n.strollerFriendly,
    9 => l10n.parking,
    10 => l10n.restrooms,
    11 => l10n.foodNearby,
    _ => l10n.other,
  };
}

/// Stitch vertical venue card (“Near you”).
class HomeNearYouVenueCard extends StatelessWidget {
  const HomeNearYouVenueCard({
    super.key,
    required this.venue,
    required this.onTap,
    required this.isFavorite,
    this.favoriteInProgress = false,
    required this.onFavoriteTap,
  });

  final VenueSummary venue;
  final VoidCallback onTap;
  final bool isFavorite;
  final bool favoriteInProgress;
  final VoidCallback onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final chips = venue.featureTypes.take(2).map((id) => _featureChipLabel(l10n, id)).toList();
    return Padding(
      padding: const EdgeInsets.only(bottom: PsSpacing.lg),
      child: Material(
        color: PsColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(PsRadii.lg),
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 192,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (venue.primaryImageUrl != null && venue.primaryImageUrl!.isNotEmpty)
                      Image.network(
                        venue.primaryImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _placeholderHero(),
                      )
                    else
                      _placeholderHero(),
                    Positioned(
                      top: PsSpacing.sm,
                      right: PsSpacing.sm,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: PsColors.surfaceContainerLowest.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                        ),
                        child: favoriteInProgress
                            ? const SizedBox(
                                width: 40,
                                height: 40,
                                child: Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: PsColors.primary),
                                  ),
                                ),
                              )
                            : IconButton(
                                onPressed: onFavoriteTap,
                                icon: Icon(
                                  isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                  color: isFavorite ? PsColors.error : PsColors.primary.withValues(alpha: 0.85),
                                ),
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                              ),
                      ),
                    ),
                    if (chips.isNotEmpty)
                      Positioned(
                        left: PsSpacing.sm,
                        bottom: PsSpacing.sm,
                        child: Wrap(
                          spacing: PsSpacing.xs,
                          runSpacing: PsSpacing.xs,
                          children: chips
                              .map(
                                (t) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: PsSpacing.sm, vertical: PsSpacing.xs),
                                  decoration: BoxDecoration(
                                    color: PsColors.surfaceContainerLowest.withValues(alpha: 0.92),
                                    borderRadius: BorderRadius.circular(PsRadii.sm),
                                  ),
                                  child: Text(
                                    t,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: PsColors.secondaryDim,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(PsSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      venue.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: PsColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: PsSpacing.xs),
                    Text(
                      '${VenueFormatters.distanceMeters(l10n, venue.distanceMeters)} · ${VenueFormatters.ageRange(l10n, venue.minAgeMonths, venue.maxAgeMonths)}',
                      style: theme.textTheme.bodySmall?.copyWith(color: PsColors.onSurfaceVariant),
                    ),
                    if (venue.hasPlaySupervisor) ...[
                      const SizedBox(height: PsSpacing.sm),
                      Row(
                        children: [
                          Icon(Icons.verified_user_rounded, size: 18, color: PsColors.secondary),
                          const SizedBox(width: PsSpacing.xs),
                          Expanded(
                            child: Text(
                              l10n.playSupervisorOnSite,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: PsColors.secondaryDim,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: PsSpacing.sm),
                    Row(
                      children: [
                        Icon(Icons.star_rounded, size: 20, color: PsColors.tertiaryContainer),
                        const SizedBox(width: PsSpacing.xs),
                        Text(
                          VenueFormatters.ratingLine(l10n, locale, venue.averageRating, venue.reviewCount),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: PsColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholderHero() {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            PsColors.primaryContainer.withValues(alpha: 0.55),
            PsColors.secondaryContainer.withValues(alpha: 0.45),
          ],
        ),
      ),
      child: Center(
        child: Icon(Icons.park_rounded, size: 56, color: PsColors.primary.withValues(alpha: 0.45)),
      ),
    );
  }
}
