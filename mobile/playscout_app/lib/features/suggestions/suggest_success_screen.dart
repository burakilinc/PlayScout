import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:playscout_app/l10n/app_localizations.dart';

import '../../app/router.dart';
import '../../design_system/design_tokens.dart';
import 'models/create_suggestion_result.dart';

class SuggestSuccessScreen extends StatelessWidget {
  const SuggestSuccessScreen({super.key, required this.result});

  final CreateSuggestionResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && context.mounted) {
          context.go(PsRoutes.home);
        }
      },
      child: Scaffold(
        backgroundColor: PsColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(PsSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              const SizedBox(height: PsSpacing.xl),
              Icon(Icons.verified_outlined, size: 56, color: PsColors.primary.withValues(alpha: 0.9)),
              const SizedBox(height: PsSpacing.lg),
              Text(
                result.confirmationTitle.isNotEmpty ? result.confirmationTitle : l10n.suggestThanksTitle,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: PsColors.onSurface,
                ),
              ),
              const SizedBox(height: PsSpacing.md),
              Text(
                result.confirmationMessage.isNotEmpty
                    ? result.confirmationMessage
                    : l10n.suggestThanksBody,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: PsColors.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: PsSpacing.lg),
              Container(
                padding: const EdgeInsets.all(PsSpacing.md),
                decoration: BoxDecoration(
                  color: PsColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(PsRadii.md),
                  border: Border.all(color: PsColors.outlineVariant.withValues(alpha: 0.25)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.moderation,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: PsColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: PsSpacing.sm),
                    Text(
                      '${l10n.statusLabel}: ${result.moderationStatusKey}',
                      style: theme.textTheme.bodyMedium?.copyWith(color: PsColors.onSurfaceVariant),
                    ),
                    const SizedBox(height: PsSpacing.sm),
                    Text(
                      l10n.notVisibleUntilReview(result.name),
                      style: theme.textTheme.bodySmall?.copyWith(color: PsColors.onSurfaceVariant, height: 1.4),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () => context.go(PsRoutes.home),
                child: Text(l10n.backToDiscover),
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SuggestSuccessFallbackScreen extends StatelessWidget {
  const SuggestSuccessFallbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && context.mounted) {
          context.go(PsRoutes.home);
        }
      },
      child: Scaffold(
        backgroundColor: PsColors.background,
        appBar: AppBar(title: Text(l10n.suggestion)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(PsSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.suggestionReceived, style: theme.textTheme.titleMedium),
                const SizedBox(height: PsSpacing.lg),
                FilledButton(onPressed: () => context.go(PsRoutes.home), child: Text(l10n.home)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
