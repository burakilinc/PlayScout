import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:playscout_app/l10n/app_localizations.dart';

import '../../../design_system/design_tokens.dart';

/// Stitch fixed top bar: park + “The Sanctuary”, tune action.
class InteractiveMapHeader extends StatelessWidget {
  const InteractiveMapHeader({
    super.key,
    required this.onTune,
  });

  final VoidCallback onTune;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: PsColors.surface.withValues(alpha: 0.8),
        boxShadow: PsColors.parkShadow(),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: PsSpacing.lg, vertical: PsSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.park_rounded, color: PsColors.primary, size: 24),
                    const SizedBox(width: PsSpacing.sm),
                    Text(
                      l10n.mapTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: PsColors.primary,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onTune,
                    borderRadius: BorderRadius.circular(9999),
                    child: Padding(
                      padding: const EdgeInsets.all(PsSpacing.sm),
                      child: Icon(Icons.tune_rounded, color: PsColors.primary, size: 24),
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
