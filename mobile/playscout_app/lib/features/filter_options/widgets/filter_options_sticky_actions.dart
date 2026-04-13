import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:playscout_app/l10n/app_localizations.dart';

import '../../../design_system/design_tokens.dart';

class FilterOptionsStickyActions extends StatelessWidget {
  const FilterOptionsStickyActions({
    super.key,
    required this.onReset,
    required this.onApply,
  });

  final VoidCallback onReset;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: PsColors.surface.withValues(alpha: 0.9),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 24,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(PsSpacing.lg),
            child: Row(
              children: [
                InkWell(
                  onTap: onReset,
                  borderRadius: BorderRadius.circular(PsRadii.sm),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: PsSpacing.sm, vertical: PsSpacing.sm),
                    child: Text(
                      l10n.filterReset,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: PsColors.onSurfaceVariant,
                        decoration: TextDecoration.underline,
                        decorationColor: PsColors.onSurfaceVariant,
                        decorationThickness: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: PsSpacing.md),
                Expanded(
                  child: Material(
                    color: PsColors.errorContainer,
                    borderRadius: BorderRadius.circular(9999),
                    elevation: 4,
                    shadowColor: PsColors.errorContainer.withValues(alpha: 0.2),
                    child: InkWell(
                      onTap: onApply,
                      borderRadius: BorderRadius.circular(9999),
                      child: SizedBox(
                        height: 56,
                        child: Center(
                          child: Text(
                            l10n.filterShowPlaces,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: PsColors.onErrorContainer,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
