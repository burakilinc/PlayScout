import 'package:flutter/material.dart';
import 'package:playscout_app/l10n/app_localizations.dart';

import '../../../design_system/design_tokens.dart';
import '../models/review_preview.dart';

/// Shared review card (translation + see-original) for venue preview and full list.
class ParentReviewCard extends StatefulWidget {
  const ParentReviewCard({super.key, required this.review});

  final ReviewPreview review;

  @override
  State<ParentReviewCard> createState() => _ParentReviewCardState();
}

class _ParentReviewCardState extends State<ParentReviewCard> {
  bool _showOriginal = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final r = widget.review;
    final initial = r.authorDisplayName.isNotEmpty ? r.authorDisplayName[0].toUpperCase() : '?';
    final body = _showOriginal && (r.originalText?.isNotEmpty ?? false) ? r.originalText! : r.displayText;
    final langLabel = r.translatedFromLanguage ?? r.originalLanguage;
    return Container(
      padding: const EdgeInsets.all(PsSpacing.lg),
      decoration: BoxDecoration(
        color: PsColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(PsRadii.md),
        boxShadow: PsColors.parkShadow(blur: 8, y: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: PsColors.primaryContainer,
                child: Text(
                  initial,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: PsColors.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: PsSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.authorDisplayName,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: PsColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: i < r.rating ? PsColors.tertiary : PsColors.outlineVariant.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: PsSpacing.md),
          Text(
            '"$body"',
            style: theme.textTheme.bodySmall?.copyWith(
              height: 1.45,
              fontStyle: FontStyle.italic,
              color: PsColors.onSurfaceVariant,
            ),
          ),
          if (r.isTranslated) ...[
            const SizedBox(height: PsSpacing.md),
            Container(
              padding: const EdgeInsets.only(top: PsSpacing.md),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: PsColors.surfaceContainer)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.translate_rounded, size: 14, color: PsColors.outlineVariant),
                  const SizedBox(width: PsSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.reviewTranslatedFrom(langLabel),
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: PsColors.outlineVariant,
                          ),
                        ),
                        if (r.showOriginalLink) ...[
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: () => setState(() => _showOriginal = !_showOriginal),
                            child: Text(
                              _showOriginal ? l10n.reviewShowTranslation : l10n.reviewSeeOriginal,
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: PsColors.primary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
