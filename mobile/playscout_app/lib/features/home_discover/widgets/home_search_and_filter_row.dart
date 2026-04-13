import 'package:flutter/material.dart';

import 'package:playscout_app/l10n/app_localizations.dart';

import '../../../design_system/design_tokens.dart';

/// Stitch search row: full-width pill + circular filter control.
class HomeSearchAndFilterRow extends StatelessWidget {
  const HomeSearchAndFilterRow({
    super.key,
    required this.onSearchTap,
    required this.onFilterTap,
  });

  final VoidCallback onSearchTap;
  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: Material(
            color: PsColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(PsRadii.xl),
            elevation: 0,
            child: InkWell(
              onTap: onSearchTap,
              borderRadius: BorderRadius.circular(PsRadii.xl),
              child: SizedBox(
                height: 56,
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    const Positioned(
                      left: PsSpacing.md,
                      child: Icon(Icons.search_rounded, color: PsColors.primary, size: 26),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 48, right: PsSpacing.md),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          l10n.homeSearchHint,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: PsColors.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: PsSpacing.sm),
        Material(
          color: PsColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(PsRadii.xl),
          child: InkWell(
            onTap: onFilterTap,
            borderRadius: BorderRadius.circular(PsRadii.xl),
            child: const SizedBox(
              width: 56,
              height: 56,
              child: Icon(Icons.tune_rounded, color: PsColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}
