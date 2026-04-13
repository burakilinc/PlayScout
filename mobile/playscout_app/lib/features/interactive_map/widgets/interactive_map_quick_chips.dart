import 'package:flutter/material.dart';
import 'package:playscout_app/l10n/app_localizations.dart';

import '../../../design_system/design_tokens.dart';

class InteractiveMapQuickChips extends StatelessWidget {
  const InteractiveMapQuickChips({
    super.key,
    required this.indoorSelected,
    required this.nearbySelected,
    required this.toddlerSelected,
    required this.onIndoor,
    required this.onNearby,
    required this.onToddler,
  });

  final bool indoorSelected;
  final bool nearbySelected;
  final bool toddlerSelected;
  final ValueChanged<bool> onIndoor;
  final ValueChanged<bool> onNearby;
  final ValueChanged<bool> onToddler;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return ScrollConfiguration(
      behavior: const _NoScrollbarScrollBehavior(),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _FreeChipPlaceholder(theme: theme),
            const SizedBox(width: PsSpacing.sm),
            _ToggleChip(
              label: l10n.indoor,
              selected: indoorSelected,
              onTap: () => onIndoor(!indoorSelected),
              theme: theme,
            ),
            const SizedBox(width: PsSpacing.sm),
            _ToggleChip(
              label: l10n.nearby,
              selected: nearbySelected,
              onTap: () => onNearby(!nearbySelected),
              theme: theme,
            ),
            const SizedBox(width: PsSpacing.sm),
            _ToggleChip(
              label: l10n.toddlerSafe,
              selected: toddlerSelected,
              onTap: () => onToddler(!toddlerSelected),
              theme: theme,
            ),
          ],
        ),
      ),
    );
  }
}

class _NoScrollbarScrollBehavior extends ScrollBehavior {
  const _NoScrollbarScrollBehavior();

  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) => child;
}

class _FreeChipPlaceholder extends StatelessWidget {
  const _FreeChipPlaceholder({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: PsSpacing.sm),
      decoration: BoxDecoration(
        color: PsColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(color: PsColors.outlineVariant.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF36392B).withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_rounded, size: 18, color: PsColors.onSurfaceVariant.withValues(alpha: 0.35)),
          const SizedBox(width: PsSpacing.xs),
          Text(
            AppLocalizations.of(context).free,
            style: theme.textTheme.labelLarge?.copyWith(
              color: PsColors.onSurfaceVariant.withValues(alpha: 0.45),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  const _ToggleChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.theme,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9999),
        child: Ink(
          decoration: BoxDecoration(
            color: selected ? PsColors.primary : PsColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(9999),
            border: Border.all(
              color: selected ? Colors.transparent : PsColors.outlineVariant.withValues(alpha: 0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF36392B).withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: PsSpacing.sm),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected) ...[
                Icon(Icons.check_rounded, size: 18, color: PsColors.onPrimary),
                const SizedBox(width: PsSpacing.xs),
              ],
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: selected ? PsColors.onPrimary : PsColors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
