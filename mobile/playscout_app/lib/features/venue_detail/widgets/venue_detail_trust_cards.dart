import 'package:flutter/material.dart';
import 'package:playscout_app/l10n/app_localizations.dart';

import '../../../design_system/design_tokens.dart';

/// Stitch trust bento: supervisor + drop-off cards (only when flags are true).
class VenueDetailTrustCards extends StatelessWidget {
  const VenueDetailTrustCards({
    super.key,
    required this.hasPlaySupervisor,
    required this.allowsChildDropOff,
  });

  final bool hasPlaySupervisor;
  final bool allowsChildDropOff;

  static const _primaryDim = Color(0xFF1B5F78);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final children = <Widget>[];
    if (hasPlaySupervisor) {
      children.add(
        _TrustCard(
          background: PsColors.secondaryContainer,
          icon: Icons.supervisor_account_rounded,
          iconTint: PsColors.secondaryDim,
          title: l10n.playSupervisorAvailable,
          titleColor: PsColors.secondaryDim,
          subtitle: l10n.trainedStaffWatchingZones,
          subtitleColor: PsColors.onSecondaryContainer,
          theme: theme,
        ),
      );
    }
    if (allowsChildDropOff) {
      children.add(
        _TrustCard(
          background: PsColors.primaryContainer,
          icon: Icons.child_friendly_rounded,
          iconTint: _primaryDim,
          title: l10n.childDropoffAllowed,
          titleColor: _primaryDim,
          subtitle: l10n.safeShortTermCareToddlers,
          subtitleColor: PsColors.onPrimaryContainer,
          theme: theme,
        ),
      );
    }
    if (children.isEmpty) {
      return const SizedBox.shrink();
    }
    if (children.length == 1) {
      return children.single;
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: children[0]),
        const SizedBox(width: PsSpacing.md),
        Expanded(child: children[1]),
      ],
    );
  }
}

class _TrustCard extends StatelessWidget {
  const _TrustCard({
    required this.background,
    required this.icon,
    required this.iconTint,
    required this.title,
    required this.titleColor,
    required this.subtitle,
    required this.subtitleColor,
    required this.theme,
  });

  final Color background;
  final IconData icon;
  final Color iconTint;
  final String title;
  final Color titleColor;
  final String subtitle;
  final Color subtitleColor;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(PsRadii.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: iconTint),
          ),
          const SizedBox(width: PsSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: subtitleColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
