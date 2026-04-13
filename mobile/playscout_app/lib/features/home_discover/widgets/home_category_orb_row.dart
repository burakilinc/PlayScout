import 'package:flutter/material.dart';
import 'package:playscout_app/l10n/app_localizations.dart';

import '../../../design_system/design_tokens.dart';
import '../models/home_stitch_category.dart';

/// Stitch horizontal category rail: circular icon + caption.
class HomeCategoryOrbRow extends StatelessWidget {
  const HomeCategoryOrbRow({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final HomeStitchCategory? selected;
  final ValueChanged<HomeStitchCategory> onSelected;

  static const _order = HomeStitchCategory.values;

  String _label(AppLocalizations l10n, HomeStitchCategory c) {
    return switch (c) {
      HomeStitchCategory.parks => l10n.homeCategoryParks,
      HomeStitchCategory.indoor => l10n.homeCategoryIndoor,
      HomeStitchCategory.events => l10n.homeCategoryEvents,
      HomeStitchCategory.cafes => l10n.homeCategoryCafes,
      HomeStitchCategory.softPlay => l10n.homeCategorySoftPlay,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: PsSpacing.lg),
        itemCount: _order.length,
        separatorBuilder: (context, index) => const SizedBox(width: PsSpacing.lg),
        itemBuilder: (context, i) {
          final c = _order[i];
          final isSel = c == selected;
          return _OrbItem(
            label: _label(l10n, c),
            icon: _iconFor(c),
            selected: isSel,
            onTap: () => onSelected(c),
          );
        },
      ),
    );
  }

  IconData _iconFor(HomeStitchCategory c) {
    return switch (c) {
      HomeStitchCategory.parks => Icons.park_rounded,
      HomeStitchCategory.indoor => Icons.sports_esports_rounded,
      HomeStitchCategory.events => Icons.event_rounded,
      HomeStitchCategory.cafes => Icons.local_cafe_rounded,
      HomeStitchCategory.softPlay => Icons.child_care_rounded,
    };
  }
}

class _OrbItem extends StatelessWidget {
  const _OrbItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(PsRadii.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: PsSpacing.xs),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: PsColors.secondaryFixed,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? PsColors.primary : Colors.transparent,
                  width: selected ? 4 : 0,
                ),
                boxShadow: selected ? PsColors.parkShadow(blur: 20, y: 4) : null,
              ),
              child: Icon(icon, color: PsColors.onSecondaryFixed, size: 30),
            ),
            const SizedBox(height: PsSpacing.sm),
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: selected ? PsColors.primary : PsColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
