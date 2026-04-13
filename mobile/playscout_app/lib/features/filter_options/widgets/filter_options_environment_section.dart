import 'package:flutter/material.dart';
import 'package:playscout_app/l10n/app_localizations.dart';

import '../../../design_system/design_tokens.dart';
import '../models/filter_environment.dart';

class FilterOptionsEnvironmentSection extends StatelessWidget {
  const FilterOptionsEnvironmentSection({
    super.key,
    required this.environment,
    required this.onSelect,
  });

  final FilterEnvironment environment;
  final ValueChanged<FilterEnvironment> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.filterEnvironmentTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: PsColors.onSurface,
          ),
        ),
        const SizedBox(height: PsSpacing.md),
        Row(
          children: [
            Expanded(
              child: _EnvCard(
                icon: Icons.home_rounded,
                label: l10n.indoor,
                selected: environment == FilterEnvironment.indoor,
                onTap: () => onSelect(FilterEnvironment.indoor),
              ),
            ),
            const SizedBox(width: PsSpacing.md),
            Expanded(
              child: _EnvCard(
                icon: Icons.park_rounded,
                label: l10n.outdoor,
                selected: environment == FilterEnvironment.outdoor,
                onTap: () => onSelect(FilterEnvironment.outdoor),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _EnvCard extends StatelessWidget {
  const _EnvCard({
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
      color: selected ? PsColors.primary : PsColors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(PsRadii.md),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(PsSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(PsRadii.md),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: PsColors.primary.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: selected ? Colors.white.withValues(alpha: 0.2) : PsColors.secondaryContainer,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  color: selected ? Colors.white : PsColors.onSecondaryContainer,
                ),
              ),
              const SizedBox(height: PsSpacing.md),
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: selected ? Colors.white : PsColors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
