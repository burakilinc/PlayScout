import 'package:flutter/material.dart';
import 'package:playscout_app/l10n/app_localizations.dart';

import '../../../design_system/design_tokens.dart';
import '../models/events_chip_state.dart';

/// Stitch horizontal chip rail — multi-select.
class EventsChipRow extends StatelessWidget {
  const EventsChipRow({
    super.key,
    required this.chips,
    required this.onToggle,
  });

  final EventsChipState chips;
  final void Function(String id) onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: PsSpacing.lg),
        physics: const BouncingScrollPhysics(),
        children: [
          _Chip(
            label: l10n.nearby,
            selected: chips.nearby,
            theme: theme,
            onTap: () => onToggle('nearby'),
          ),
          const SizedBox(width: PsSpacing.sm),
          _Chip(
            label: l10n.thisWeekend,
            selected: chips.thisWeekend,
            theme: theme,
            onTap: () => onToggle('weekend'),
          ),
          const SizedBox(width: PsSpacing.sm),
          _Chip(
            label: l10n.free,
            selected: chips.free,
            theme: theme,
            onTap: () => onToggle('free'),
          ),
          const SizedBox(width: PsSpacing.sm),
          _Chip(
            label: l10n.indoor,
            selected: chips.indoor,
            theme: theme,
            onTap: () => onToggle('indoor'),
          ),
          const SizedBox(width: PsSpacing.sm),
          _Chip(
            label: l10n.age0to5,
            selected: chips.age05,
            theme: theme,
            onTap: () => onToggle('age05'),
          ),
          const SizedBox(width: PsSpacing.sm),
          _Chip(
            label: l10n.age6to10,
            selected: chips.age610,
            theme: theme,
            onTap: () => onToggle('age610'),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.theme,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final ThemeData theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9999),
        child: Ink(
          decoration: BoxDecoration(
            color: selected ? PsColors.primary : PsColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(9999),
            boxShadow: PsColors.parkShadow(blur: 4, y: 2),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: PsSpacing.sm),
          child: Center(
            child: Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: selected ? PsColors.onPrimary : PsColors.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
