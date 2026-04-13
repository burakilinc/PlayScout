import 'package:flutter/material.dart';

import '../../../design_system/design_tokens.dart';

/// Centered message over the decorative map when [GET /venues/nearby] returns no rows.
class InteractiveMapEmptyOverlay extends StatelessWidget {
  const InteractiveMapEmptyOverlay({
    super.key,
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: PsSpacing.xl),
        child: Material(
          color: PsColors.surfaceContainerLowest.withValues(alpha: 0.94),
          elevation: 4,
          shadowColor: const Color(0xFF36392B).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(PsRadii.lg),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: PsSpacing.xl, vertical: PsSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.explore_outlined, size: 40, color: PsColors.primary.withValues(alpha: 0.55)),
                const SizedBox(height: PsSpacing.md),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: PsColors.onSurface,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: PsSpacing.sm),
                  Text(
                    subtitle!,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: PsColors.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
