import 'package:flutter/material.dart';
import 'package:playscout_app/l10n/app_localizations.dart';

import '../../../design_system/design_tokens.dart';
import '../map_feature_chip_labels.dart';
import '../../home_discover/models/venue_summary.dart';
import 'interactive_map_distance_format.dart';

class InteractiveMapPreviewCard extends StatelessWidget {
  const InteractiveMapPreviewCard({
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
    final chips = MapFeatureChipLabels.previewLabels(l10n, venue);
    return Material(
      color: PsColors.surfaceContainerLowest,
      elevation: 8,
      shadowColor: const Color(0xFF36392B).withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(PsRadii.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(PsRadii.md),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(PsRadii.md),
            border: Border.all(color: PsColors.outlineVariant.withValues(alpha: 0.05)),
          ),
          padding: const EdgeInsets.all(PsSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(PsRadii.sm),
                child: SizedBox(
                  width: 96,
                  height: 96,
                  child: venue.primaryImageUrl != null
                      ? Image.network(
                          venue.primaryImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => ColoredBox(
                            color: PsColors.surfaceContainerHigh,
                            child: Icon(Icons.image_not_supported_outlined,
                                color: PsColors.onSurfaceVariant.withValues(alpha: 0.4)),
                          ),
                        )
                      : ColoredBox(
                          color: PsColors.surfaceContainerHigh,
                          child: Icon(Icons.park_rounded, color: PsColors.primary.withValues(alpha: 0.35), size: 40),
                        ),
                ),
              ),
              const SizedBox(width: PsSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                venue.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: PsColors.onSurface,
                                  fontWeight: FontWeight.w800,
                                  height: 1.2,
                                ),
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star_rounded, size: 16, color: PsColors.tertiary),
                                const SizedBox(width: 2),
                                Text(
                                  venue.averageRating != null ? venue.averageRating!.toStringAsFixed(1) : l10n.dashEmDash,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: PsColors.onSurface,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: onFavoriteTap,
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                              icon: Icon(
                                isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                size: 22,
                                color: isFavorite ? PsColors.error : PsColors.onSurfaceVariant.withValues(alpha: 0.65),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: PsSpacing.xs),
                        Text(
                          InteractiveMapDistanceFormat.kmAway(l10n, venue.distanceMeters),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: PsColors.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    if (chips.isNotEmpty) ...[
                      const SizedBox(height: PsSpacing.sm),
                      Wrap(
                        spacing: PsSpacing.sm,
                        runSpacing: PsSpacing.xs,
                        children: [
                          for (var i = 0; i < chips.length; i++)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: i == 0 ? PsColors.secondaryContainer : PsColors.primaryContainer,
                                borderRadius: BorderRadius.circular(9999),
                              ),
                              child: Text(
                                chips[i].toUpperCase(),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontSize: 10,
                                  letterSpacing: 0.8,
                                  fontWeight: FontWeight.w800,
                                  color: i == 0 ? PsColors.onSecondaryContainer : PsColors.onPrimaryContainer,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
