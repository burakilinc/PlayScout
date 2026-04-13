import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:playscout_app/l10n/app_localizations.dart';

import '../../app/auth_scope.dart';
import '../../app/router.dart';
import '../../design_system/design_tokens.dart';
import 'auth_session.dart';

/// Lightweight account hub: sign-in upsell for guests, sign-out for members.
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final session = AuthScope.of(context);

    return Scaffold(
      backgroundColor: PsColors.background,
      appBar: AppBar(
        title: Text(l10n.accountScreenTitle),
      ),
      body: ListenableBuilder(
        listenable: session,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(PsSpacing.lg),
            children: [
              if (session.hasMemberSession) ...[
                Text(
                  l10n.accountMemberSignedIn,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: PsColors.onSurface,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: PsSpacing.xl),
                FilledButton.tonal(
                  onPressed: () => _signOut(context, session),
                  child: Text(l10n.accountSignOut),
                ),
              ] else if (session.isGuestSession) ...[
                Text(
                  l10n.accountGuestSignedIn,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: PsColors.onSurface,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: PsSpacing.xl),
                FilledButton(
                  onPressed: () => context.push(PsRoutes.authWelcome),
                  child: Text(l10n.navSignInEntry),
                ),
                const SizedBox(height: PsSpacing.md),
                OutlinedButton(
                  onPressed: () => _signOut(context, session),
                  child: Text(l10n.accountSignOut),
                ),
              ] else ...[
                Text(
                  l10n.accountSignedOutBlurb,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: PsColors.onSurface,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: PsSpacing.xl),
                FilledButton(
                  onPressed: () => context.push(PsRoutes.authWelcome),
                  child: Text(l10n.navSignInEntry),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _signOut(BuildContext context, AuthSession session) async {
    await session.signOut();
    if (context.mounted) context.go(PsRoutes.home);
  }
}
