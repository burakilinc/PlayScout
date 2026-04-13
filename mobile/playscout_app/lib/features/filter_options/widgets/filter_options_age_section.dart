import 'package:flutter/material.dart';
import 'package:playscout_app/l10n/app_localizations.dart';

import '../../../design_system/design_tokens.dart';
import '../models/filter_age_band.dart';

class FilterOptionsAgeSection extends StatelessWidget {
  const FilterOptionsAgeSection({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  final FilterAgeBand? selected;
  final ValueChanged<FilterAgeBand> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.filterAgeSuitabilityTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: PsColors.onSurface,
          ),
        ),
        const SizedBox(height: PsSpacing.md),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _AgeChip(
              label: l10n.filterAge02,
              selected: selected == FilterAgeBand.zeroTwo,
              onTap: () => onSelect(FilterAgeBand.zeroTwo),
            ),
            _AgeChip(
              label: l10n.filterAge35,
              selected: selected == FilterAgeBand.threeFive,
              onTap: () => onSelect(FilterAgeBand.threeFive),
            ),
            _AgeChip(
              label: l10n.filterAge610,
              selected: selected == FilterAgeBand.sixTen,
              onTap: () => onSelect(FilterAgeBand.sixTen),
            ),
          ],
        ),
      ],
    );
  }
}

class _AgeChip extends StatelessWidget {
  const _AgeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: selected ? PsColors.primary : PsColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(9999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: PsSpacing.lg, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9999),
            border: Border.all(
              color: selected ? PsColors.primary : PsColors.primaryContainer,
              width: 2,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: PsColors.primary.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: selected ? Colors.white : PsColors.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
