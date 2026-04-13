import 'package:flutter/material.dart';
import 'package:playscout_app/l10n/app_localizations.dart';

import '../../../design_system/design_tokens.dart';
import '../models/amenity_feature_ids.dart';

class FilterOptionsAmenitiesGrid extends StatelessWidget {
  const FilterOptionsAmenitiesGrid({
    super.key,
    required this.selectedIds,
    required this.onToggle,
  });

  final Set<int> selectedIds;
  final ValueChanged<int> onToggle;

  static const _tiles = <({int id, IconData icon})>[
    (id: AmenityFeatureIds.toilet, icon: Icons.wc_rounded),
    (id: AmenityFeatureIds.parking, icon: Icons.local_parking_rounded),
    (id: AmenityFeatureIds.foodDrinks, icon: Icons.restaurant_rounded),
    (id: AmenityFeatureIds.shade, icon: Icons.wb_sunny_rounded),
    (id: AmenityFeatureIds.stroller, icon: Icons.stroller_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    String labelFor(int id) {
      return switch (id) {
        AmenityFeatureIds.toilet => l10n.toilet,
        AmenityFeatureIds.parking => l10n.parking,
        AmenityFeatureIds.foodDrinks => l10n.foodAndDrinks,
        AmenityFeatureIds.shade => l10n.shade,
        AmenityFeatureIds.stroller => l10n.stroller,
        _ => '',
      };
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.filterAmenitiesTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: PsColors.onSurface,
          ),
        ),
        const SizedBox(height: PsSpacing.md),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.95,
          children: _tiles
              .map(
                (t) => _AmenityTile(
                  icon: t.icon,
                  label: labelFor(t.id),
                  selected: selectedIds.contains(t.id),
                  onTap: () => onToggle(t.id),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _AmenityTile extends StatelessWidget {
  const _AmenityTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: selected ? PsColors.primaryContainer : PsColors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(PsRadii.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(PsRadii.md),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(PsRadii.md),
            border: selected ? Border.all(color: PsColors.primary.withValues(alpha: 0.15)) : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: selected ? PsColors.primary : PsColors.tertiary,
                size: 26,
              ),
              const SizedBox(height: PsSpacing.sm),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: selected ? PsColors.onPrimaryContainer : PsColors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
