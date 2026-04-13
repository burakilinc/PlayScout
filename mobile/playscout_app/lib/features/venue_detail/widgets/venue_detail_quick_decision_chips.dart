import 'package:flutter/material.dart';
import 'package:playscout_app/l10n/app_localizations.dart';

import '../../../design_system/design_tokens.dart';

/// Stitch quick-decision chip row (only chips backed by API data).
class VenueDetailQuickDecisionChips extends StatelessWidget {
  const VenueDetailQuickDecisionChips({
    super.key,
    required this.ageChipLabel,
    this.showIndoor = false,
    this.showOutdoor = false,
  });

  final String ageChipLabel;
  final bool showIndoor;
  final bool showOutdoor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chips = <Widget>[
      _Chip(
        icon: Icons.child_care_rounded,
        label: ageChipLabel,
        theme: theme,
      ),
    ];
    if (showIndoor) {
      chips.add(
        _Chip(
          icon: Icons.home_rounded,
          label: AppLocalizations.of(context).indoor,
          theme: theme,
        ),
      );
    } else if (showOutdoor) {
      chips.add(
        _Chip(
          icon: Icons.park_rounded,
          label: AppLocalizations.of(context).outdoor,
          theme: theme,
        ),
      );
    }
    return Wrap(
      spacing: PsSpacing.sm,
      runSpacing: PsSpacing.sm,
      children: chips,
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.icon,
    required this.label,
    required this.theme,
  });

  final IconData icon;
  final String label;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: PsSpacing.md, vertical: PsSpacing.sm),
      decoration: BoxDecoration(
        color: PsColors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: PsColors.onSurface),
          const SizedBox(width: PsSpacing.sm),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: PsColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
