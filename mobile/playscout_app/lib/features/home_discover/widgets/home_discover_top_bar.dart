import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:playscout_app/l10n/app_localizations.dart';

import '../../../app/auth_scope.dart';
import '../../../design_system/design_tokens.dart';

/// Stitch `<header>`: title, location selector affordance, notifications (no bottom nav).
class HomeDiscoverTopBar extends StatelessWidget {
  const HomeDiscoverTopBar({
    super.key,
    required this.locationLabel,
    required this.onLocationTap,
    required this.onLanguageTap,
    required this.onNotificationsTap,
    required this.onAccountTap,
  });

  final String locationLabel;
  final VoidCallback onLocationTap;
  final VoidCallback onLanguageTap;
  final VoidCallback onNotificationsTap;
  final VoidCallback onAccountTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final auth = AuthScope.of(context);
    final accountLabel = !auth.isAuthenticated
        ? l10n.navSignInEntry
        : auth.hasMemberSession
            ? l10n.navMyProfileEntry
            : l10n.navMyAccountEntry;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: PsColors.surface.withValues(alpha: 0.82),
            border: Border(
              bottom: BorderSide(color: PsColors.outlineVariant.withValues(alpha: 0.35)),
            ),
            boxShadow: PsColors.parkShadow(blur: 32, y: 8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: PsSpacing.lg, vertical: PsSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'PlayScout',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: PsColors.primary,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onAccountTap,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: PsSpacing.sm, vertical: PsSpacing.xs),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    accountLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: PsColors.primary,
                    ),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onLocationTap,
                    borderRadius: BorderRadius.circular(PsRadii.sm),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: PsSpacing.sm, vertical: PsSpacing.xs),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_on_rounded, size: 20, color: PsColors.primary),
                          const SizedBox(width: PsSpacing.xs),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 120),
                            child: Text(
                              locationLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: PsColors.onSurface,
                              ),
                            ),
                          ),
                          Icon(Icons.expand_more_rounded, color: PsColors.onSurfaceVariant, size: 22),
                        ],
                      ),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: l10n.languageTitle,
                  onPressed: onLanguageTap,
                  icon: Icon(Icons.language_rounded, color: PsColors.onSurface.withValues(alpha: 0.85)),
                ),
                IconButton(
                  tooltip: l10n.notificationsTooltip,
                  onPressed: onNotificationsTap,
                  icon: Icon(Icons.notifications_none_rounded, color: PsColors.onSurface.withValues(alpha: 0.85)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
