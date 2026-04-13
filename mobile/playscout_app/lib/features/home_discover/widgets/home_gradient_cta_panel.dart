import 'package:flutter/material.dart';

import 'package:playscout_app/l10n/app_localizations.dart';

import '../../../design_system/design_tokens.dart';

/// Stitch gradient CTA card (“Where should we go now?”) + illustration.
class HomeGradientCtaPanel extends StatelessWidget {
  const HomeGradientCtaPanel({
    super.key,
    required this.onPressed,
    this.illustrationUrl = _defaultCtaImageUrl,
  });

  final VoidCallback onPressed;
  final String illustrationUrl;

  /// Placeholder hero; Stitch asset URL can be swapped when bundled.
  static const _defaultCtaImageUrl =
      'https://images.unsplash.com/photo-1544776193-3527fbfda82b?w=480&q=80';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(PsRadii.lg),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  PsColors.primary,
                  PsColors.primaryContainerGradientEnd,
                ],
              ),
            ),
            child: const SizedBox(width: double.infinity, height: 220),
          ),
          Positioned(
            right: -PsSpacing.md,
            bottom: -PsSpacing.sm,
            width: 160,
            height: 160,
            child: Image.network(
              illustrationUrl,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.directions_run_rounded,
                size: 120,
                color: PsColors.onPrimary.withValues(alpha: 0.35),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(PsSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.homeCtaTitle,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: PsColors.onPrimary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: PsSpacing.sm),
                Text(
                  l10n.homeCtaSubtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: PsColors.onPrimary.withValues(alpha: 0.92),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: PsSpacing.lg),
                FilledButton(
                  onPressed: onPressed,
                  style: FilledButton.styleFrom(
                    backgroundColor: PsColors.errorContainer,
                    foregroundColor: PsColors.onErrorContainer,
                    padding: const EdgeInsets.symmetric(horizontal: PsSpacing.lg, vertical: PsSpacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(PsRadii.sm),
                    ),
                  ),
                  child: Text(
                    l10n.homeCtaButton,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: PsColors.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
