import 'package:flutter/material.dart';
import 'package:playscout_app/l10n/app_localizations.dart';

import '../../../design_system/design_tokens.dart';
import '../models/review_preview.dart';
import 'parent_review_card.dart';

/// Stitch "Parent Reviews" block with up to two preview cards.
class VenueDetailReviewsPreview extends StatelessWidget {
  const VenueDetailReviewsPreview({
    super.key,
    required this.reviews,
    required this.onViewAll,
    required this.onWriteReview,
  });

  final List<ReviewPreview> reviews;
  final VoidCallback onViewAll;
  final VoidCallback onWriteReview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final preview = reviews.take(2).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.venueParentReviews,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: PsColors.onSurface,
                ),
              ),
            ),
            TextButton(
              onPressed: onViewAll,
              child: Text(
                l10n.venueViewAll,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: PsColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: PsSpacing.lg),
        if (preview.isEmpty)
          Text(
            l10n.venueNoReviewsYet,
            style: theme.textTheme.bodyMedium?.copyWith(color: PsColors.onSurfaceVariant),
          )
        else
          Column(
            children: [
              for (final r in preview) ...[
                ParentReviewCard(review: r),
                const SizedBox(height: PsSpacing.md),
              ],
            ],
          ),
        const SizedBox(height: PsSpacing.lg),
        SizedBox(
          width: double.infinity,
          child: FilledButton.tonal(
            onPressed: onWriteReview,
            child: Text(l10n.writeReview),
          ),
        ),
      ],
    );
  }
}
