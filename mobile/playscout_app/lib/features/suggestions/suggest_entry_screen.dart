import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:playscout_app/l10n/app_localizations.dart';

import '../../app/router.dart';
import '../../design_system/design_tokens.dart';
import '../auth/models/pending_auth_intent.dart';
import '../auth/protected_member_action.dart';

/// Landing for “Suggest a place” — member goes straight to form; guest sees gate first.
class SuggestEntryScreen extends StatelessWidget {
  const SuggestEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: PsColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(l10n.suggestPlaceTitle),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(PsSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.suggestKnowGreatSpot,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: PsColors.onSurface,
                ),
              ),
              const SizedBox(height: PsSpacing.md),
              Text(
                l10n.suggestEntryLead,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: PsColors.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () async {
                  await playScoutRequireFullMember(
                    context,
                    resumeIfGuest: PendingAuthIntent.suggestPlaceForm,
                    whenMember: () async {
                      if (context.mounted) await context.push(PsRoutes.suggestForm);
                    },
                  );
                },
                child: Text(l10n.startSuggestion),
              ),
              const SizedBox(height: PsSpacing.md),
              Text(
                l10n.fullMemberRequired,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(color: PsColors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
