import 'package:flutter/material.dart';
import 'package:playscout_app/l10n/app_localizations.dart';

import '../../../design_system/design_tokens.dart';

class FilterOptionsTrustSafetySection extends StatelessWidget {
  const FilterOptionsTrustSafetySection({
    super.key,
    required this.playSupervisor,
    required this.childDropOff,
    required this.onToggleSupervisor,
    required this.onToggleDropOff,
  });

  final bool playSupervisor;
  final bool childDropOff;
  final VoidCallback onToggleSupervisor;
  final VoidCallback onToggleDropOff;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.filterTrustSafetyTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: PsColors.onSurface,
          ),
        ),
        const SizedBox(height: PsSpacing.md),
        _TrustCard(
          selected: playSupervisor,
          onTap: onToggleSupervisor,
          background: PsColors.secondaryContainer.withValues(alpha: 0.3),
          borderColor: PsColors.secondary.withValues(alpha: 0.1),
          iconBg: PsColors.secondaryFixed,
          icon: Icons.verified_user_rounded,
          iconColor: PsColors.onSecondaryContainer,
          title: l10n.playSupervisorAvailable,
          titleColor: PsColors.onSecondaryContainer,
          subtitle: l10n.filterTrustSupervisorLongSubtitle,
          subtitleColor: PsColors.onSecondaryFixedVariant.withValues(alpha: 0.8),
          watermark: Icons.shield_rounded,
        ),
        const SizedBox(height: 12),
        _TrustCard(
          selected: childDropOff,
          onTap: onToggleDropOff,
          background: PsColors.primaryContainer.withValues(alpha: 0.3),
          borderColor: PsColors.primary.withValues(alpha: 0.1),
          iconBg: PsColors.primaryContainer,
          icon: Icons.escalator_warning_rounded,
          iconColor: PsColors.onPrimaryContainer,
          title: l10n.childDropoffAllowed,
          titleColor: PsColors.onPrimaryContainer,
          subtitle: l10n.designatedSecureZones,
          subtitleColor: PsColors.onPrimaryContainer.withValues(alpha: 0.8),
          watermark: Icons.child_care_rounded,
        ),
      ],
    );
  }
}

class _TrustCard extends StatelessWidget {
  const _TrustCard({
    required this.selected,
    required this.onTap,
    required this.background,
    required this.borderColor,
    required this.iconBg,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.titleColor,
    required this.subtitle,
    required this.subtitleColor,
    required this.watermark,
  });

  final bool selected;
  final VoidCallback onTap;
  final Color background;
  final Color borderColor;
  final Color iconBg;
  final IconData icon;
  final Color iconColor;
  final String title;
  final Color titleColor;
  final String subtitle;
  final Color subtitleColor;
  final IconData watermark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(PsRadii.md),
        child: Ink(
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(PsRadii.md),
            border: Border.all(
              color: selected ? PsColors.primary : borderColor,
              width: selected ? 2 : 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(PsRadii.md),
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: iconBg,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Icon(icon, size: 32, color: iconColor),
                      ),
                      const SizedBox(width: PsSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: titleColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 12,
                                height: 1.35,
                                color: subtitleColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: -16,
                  bottom: -16,
                  child: Icon(
                    watermark,
                    size: 120,
                    color: titleColor.withValues(alpha: 0.08),
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
