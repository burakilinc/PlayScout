import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../design_system/design_tokens.dart';

/// Stitch title + stats row: name, distance, star rating, review count.
class VenueDetailTitleStats extends StatelessWidget {
  const VenueDetailTitleStats({
    super.key,
    required this.name,
    required this.distanceLine,
    required this.reviewCountLabel,
    required this.averageRating,
  });

  final String name;
  final String distanceLine;
  final String reviewCountLabel;
  final double? averageRating;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = Localizations.localeOf(context).toLanguageTag();
    final ratingStr =
        averageRating != null ? NumberFormat('0.0', loc).format(averageRating!) : '—';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: PsColors.onSurface,
          ),
        ),
        const SizedBox(height: PsSpacing.sm),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: PsSpacing.sm,
          runSpacing: PsSpacing.xs,
          children: [
            Text(
              distanceLine,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: PsColors.onSurfaceVariant,
              ),
            ),
            Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(color: PsColors.outlineVariant, shape: BoxShape.circle),
            ),
            Icon(Icons.star_rounded, size: 18, color: PsColors.tertiary),
            const SizedBox(width: 2),
            Text(
              ratingStr,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: PsColors.tertiary,
              ),
            ),
            Text(
              reviewCountLabel,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: PsColors.outlineVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
