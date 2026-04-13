import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:playscout_app/l10n/app_localizations.dart';

import '../../design_system/design_tokens.dart';
import 'models/search_flow_args.dart';
import 'widgets/search_filter_chips_row.dart';

/// Stitch `no_results_found` — readonly query bar, same chips (non-interactive), reset returns to results.
class SearchEmptyScreen extends StatelessWidget {
  const SearchEmptyScreen({super.key, required this.args});

  final SearchFlowArgs args;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: PsColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(PsSpacing.sm, PsSpacing.sm, PsSpacing.sm, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    color: PsColors.onSurface,
                  ),
                  Expanded(
                    child: Material(
                      color: PsColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(PsRadii.xl),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: PsSpacing.md, vertical: PsSpacing.md),
                        child: Row(
                          children: [
                            const Icon(Icons.search_rounded, color: PsColors.primary),
                            const SizedBox(width: PsSpacing.sm),
                            Expanded(
                              child: Text(
                                args.query.isEmpty ? l10n.search : args.query,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: PsColors.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: Text(l10n.cancel),
                  ),
                ],
              ),
            ),
            const SizedBox(height: PsSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: PsSpacing.lg),
              child: SearchFilterChipsRow(
                nearbySelected: args.nearbyChip,
                freeSelected: args.freeChip,
                indoorSelected: args.indoorChip,
                age05Selected: args.age05Chip,
                onNearby: (_) {},
                onFree: (_) {},
                onIndoor: (_) {},
                onAge05: (_) {},
                interactive: false,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(PsSpacing.lg),
                child: Column(
                  children: [
                    const Spacer(),
                    Icon(
                      Icons.travel_explore_rounded,
                      size: 96,
                      color: PsColors.primary.withValues(alpha: 0.35),
                    ),
                    const SizedBox(height: PsSpacing.lg),
                    Text(
                      'No results found',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: PsColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: PsSpacing.md),
                    Text(
                      'Try clearing quick filters or widening your saved filters from the tune menu.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: PsColors.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => context.pop(true),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: PsSpacing.md),
                          backgroundColor: PsColors.primary,
                          foregroundColor: PsColors.onPrimary,
                        ),
                        child: Text(l10n.resetFilters),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
