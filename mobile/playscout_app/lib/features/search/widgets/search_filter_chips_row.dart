import 'package:flutter/material.dart';
import 'package:playscout_app/l10n/app_localizations.dart';

import '../../../design_system/design_tokens.dart';

/// Stitch-aligned quick filters for Search Results and No Results (Nearby, Free, Indoor, Age 0–5).
/// [onFreeChanged] affects UI only; other toggles are intended to drive refetch logic in the parent.
class SearchFilterChipsRow extends StatelessWidget {
  const SearchFilterChipsRow({
    super.key,
    required this.nearbySelected,
    required this.freeSelected,
    required this.indoorSelected,
    required this.age05Selected,
    required this.onNearby,
    required this.onFree,
    required this.onIndoor,
    required this.onAge05,
    this.interactive = true,
  });

  final bool nearbySelected;
  final bool freeSelected;
  final bool indoorSelected;
  final bool age05Selected;
  final ValueChanged<bool> onNearby;
  final ValueChanged<bool> onFree;
  final ValueChanged<bool> onIndoor;
  final ValueChanged<bool> onAge05;
  final bool interactive;

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
            _ToggleChip(
              label: l10n.nearby,
              selected: nearbySelected,
              onTap: interactive ? () => onNearby(!nearbySelected) : null,
              theme: theme,
            ),
            const SizedBox(width: PsSpacing.sm),
            _FreeChip(
              selected: freeSelected,
              onTap: interactive ? () => onFree(!freeSelected) : null,
              theme: theme,
            ),
            const SizedBox(width: PsSpacing.sm),
            _ToggleChip(
              label: l10n.indoor,
              selected: indoorSelected,
              onTap: interactive ? () => onIndoor(!indoorSelected) : null,
              theme: theme,
            ),
            const SizedBox(width: PsSpacing.sm),
            _ToggleChip(
              label: l10n.age0to5,
              selected: age05Selected,
              onTap: interactive ? () => onAge05(!age05Selected) : null,
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

class _FreeChip extends StatelessWidget {
  const _FreeChip({
    required this.selected,
    required this.onTap,
    required this.theme,
  });

  final bool selected;
  final VoidCallback? onTap;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9999),
        child: Ink(
          decoration: BoxDecoration(
            color: selected ? PsColors.secondaryContainer : PsColors.surfaceContainerLowest,
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
              Icon(
                Icons.check_rounded,
                size: 18,
                color: selected
                    ? PsColors.onSecondaryContainer
                    : PsColors.onSurfaceVariant.withValues(alpha: enabled ? 0.35 : 0.2),
              ),
              const SizedBox(width: PsSpacing.xs),
              Text(
                AppLocalizations.of(context).free,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: selected
                      ? PsColors.onSecondaryContainer
                      : PsColors.onSurfaceVariant.withValues(alpha: enabled ? 0.75 : 0.45),
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

class _ToggleChip extends StatelessWidget {
  const _ToggleChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.theme,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
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
