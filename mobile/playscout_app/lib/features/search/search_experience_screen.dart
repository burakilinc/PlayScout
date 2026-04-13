import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:playscout_app/l10n/app_localizations.dart';

import '../../app/app_criteria_scope.dart';
import '../../app/router.dart';
import '../../design_system/design_tokens.dart';
import '../filter_options/models/filter_environment.dart';
import '../filter_options/models/venue_nearby_criteria.dart';
import 'data/recent_searches_repository.dart';
import 'models/search_flow_args.dart';

/// Stitch `search_experience` — dedicated layout (no shell bottom nav in body).
class SearchExperienceScreen extends StatefulWidget {
  const SearchExperienceScreen({super.key});

  @override
  State<SearchExperienceScreen> createState() => _SearchExperienceScreenState();
}

class _SearchExperienceScreenState extends State<SearchExperienceScreen> {
  final TextEditingController _query = TextEditingController();
  final RecentSearchesRepository _recentRepo = RecentSearchesRepository();
  List<String> _recent = const [];

  List<String> _popularQueries(AppLocalizations l10n) => [
        l10n.popularPlayground,
        l10n.popularParkWithCafe,
        l10n.popularSoftPlay,
        l10n.popularWaterPlay,
      ];

  @override
  void initState() {
    super.initState();
    _refreshRecent();
  }

  Future<void> _refreshRecent() async {
    final r = await _recentRepo.load();
    if (!mounted) return;
    setState(() => _recent = r);
  }

  Future<void> _openFilter(BuildContext context) async {
    final app = AppCriteriaScope.of(context);
    final r = await context.push<VenueNearbyCriteria>(
      PsRoutes.filter,
      extra: app.criteria,
    );
    if (!mounted || r == null) return;
    app.setCriteria(r);
  }

  void _submitSearch(BuildContext context) {
    final q = _query.text.trim();
    if (q.isNotEmpty) {
      _recentRepo.add(q);
    }
    context.push(PsRoutes.searchResults, extra: SearchFlowArgs(query: q));
  }

  void _goResultsWithShortcut(BuildContext context, {required SearchFlowArgs args}) {
    context.push(PsRoutes.searchResults, extra: args);
  }

  void _applyCategoryAndResults(
    BuildContext context, {
    required VenueNearbyCriteria nextCriteria,
    String query = '',
  }) {
    AppCriteriaScope.of(context).setCriteria(nextCriteria);
    _goResultsWithShortcut(context, args: SearchFlowArgs(query: query));
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

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
                      color: PsColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(PsRadii.xl),
                      child: TextField(
                        controller: _query,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) => _submitSearch(context),
                        decoration: InputDecoration(
                          hintText: l10n.mapSearchParksIndoorHint,
                          hintStyle: theme.textTheme.bodyLarge?.copyWith(
                            color: PsColors.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                          prefixIcon: const Icon(Icons.search_rounded, color: PsColors.primary, size: 26),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: PsSpacing.sm, vertical: PsSpacing.md),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: PsSpacing.sm),
                  Material(
                    color: PsColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(PsRadii.xl),
                    child: InkWell(
                      onTap: () => _openFilter(context),
                      borderRadius: BorderRadius.circular(PsRadii.xl),
                      child: const SizedBox(
                        width: 52,
                        height: 52,
                        child: Icon(Icons.tune_rounded, color: PsColors.primary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(PsSpacing.lg, PsSpacing.lg, PsSpacing.lg, PsSpacing.md),
                children: [
                  Text(
                    l10n.searchPopularSearches,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: PsColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: PsSpacing.md),
                  Wrap(
                    spacing: PsSpacing.sm,
                    runSpacing: PsSpacing.sm,
                    children: [
                      for (final p in _popularQueries(l10n))
                        ActionChip(
                          label: Text(p),
                          onPressed: () {
                            _recentRepo.add(p);
                            _goResultsWithShortcut(context, args: SearchFlowArgs(query: p));
                          },
                          backgroundColor: PsColors.surfaceContainerLow,
                          side: BorderSide(color: PsColors.outlineVariant.withValues(alpha: 0.35)),
                        ),
                    ],
                  ),
                  const SizedBox(height: PsSpacing.xl),
                  Text(
                    l10n.searchSuggestedForYou,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: PsColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: PsSpacing.md),
                  _CategoryShortcutGrid(
                    onParks: () {
                      final app = AppCriteriaScope.of(context);
                      _applyCategoryAndResults(
                        context,
                        nextCriteria: app.criteria.copyWith(environment: FilterEnvironment.outdoor),
                      );
                    },
                    onIndoor: () {
                      final app = AppCriteriaScope.of(context);
                      _applyCategoryAndResults(
                        context,
                        nextCriteria: app.criteria.copyWith(environment: FilterEnvironment.indoor),
                      );
                    },
                    onEvents: () => context.push(PsRoutes.events),
                    onCafes: () {
                      final app = AppCriteriaScope.of(context);
                      final ids = {...app.criteria.amenityFeatureTypeIds, 11};
                      _applyCategoryAndResults(
                        context,
                        nextCriteria: app.criteria.copyWith(
                          environment: FilterEnvironment.none,
                          amenityFeatureTypeIds: ids,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: PsSpacing.xl),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.searchRecentSearches,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: PsColors.onSurface,
                          ),
                        ),
                      ),
                      if (_recent.isNotEmpty)
                        TextButton(
                          onPressed: () async {
                            await _recentRepo.clear();
                            await _refreshRecent();
                          },
                          child: Text(l10n.searchClearHistory),
                        ),
                    ],
                  ),
                  const SizedBox(height: PsSpacing.sm),
                  if (_recent.isEmpty)
                    Text(
                      l10n.searchNoRecentYet,
                      style: theme.textTheme.bodyMedium?.copyWith(color: PsColors.onSurfaceVariant),
                    )
                  else
                    Column(
                      children: [
                        for (final r in _recent)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.history_rounded, color: PsColors.primary),
                            title: Text(r, maxLines: 1, overflow: TextOverflow.ellipsis),
                            trailing: IconButton(
                              icon: const Icon(Icons.close_rounded, size: 20),
                              onPressed: () async {
                                await _recentRepo.remove(r);
                                await _refreshRecent();
                              },
                              color: PsColors.onSurfaceVariant,
                            ),
                            onTap: () => _goResultsWithShortcut(context, args: SearchFlowArgs(query: r)),
                          ),
                      ],
                    ),
                ],
              ),
            ),
            const _SearchExperienceHintPanel(),
          ],
        ),
      ),
    );
  }
}

class _CategoryShortcutGrid extends StatelessWidget {
  const _CategoryShortcutGrid({
    required this.onParks,
    required this.onIndoor,
    required this.onEvents,
    required this.onCafes,
  });

  final VoidCallback onParks;
  final VoidCallback onIndoor;
  final VoidCallback onEvents;
  final VoidCallback onCafes;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: PsSpacing.md,
      crossAxisSpacing: PsSpacing.md,
      childAspectRatio: 1.15,
      children: [
        _CategoryTile(
          label: AppLocalizations.of(context).parks,
          icon: Icons.park_rounded,
          tint: PsColors.secondary,
          onTap: onParks,
        ),
        _CategoryTile(
          label: AppLocalizations.of(context).indoor,
          icon: Icons.home_work_rounded,
          tint: PsColors.primary,
          onTap: onIndoor,
        ),
        _CategoryTile(
          label: AppLocalizations.of(context).navEvents,
          icon: Icons.event_available_rounded,
          tint: PsColors.tertiary,
          onTap: onEvents,
        ),
        _CategoryTile(
          label: AppLocalizations.of(context).cafes,
          icon: Icons.local_cafe_rounded,
          tint: PsColors.tertiary,
          onTap: onCafes,
        ),
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.label,
    required this.icon,
    required this.tint,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: PsColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(PsRadii.md),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(PsRadii.md),
        child: Padding(
          padding: const EdgeInsets.all(PsSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(PsRadii.sm),
                ),
                child: Icon(icon, color: tint),
              ),
              const Spacer(),
              Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: PsColors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchExperienceHintPanel extends StatelessWidget {
  const _SearchExperienceHintPanel();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(PsSpacing.lg, PsSpacing.md, PsSpacing.lg, PsSpacing.lg),
      decoration: BoxDecoration(
        color: PsColors.surfaceContainer,
        border: Border(top: BorderSide(color: PsColors.outlineVariant.withValues(alpha: 0.35))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline_rounded, color: PsColors.primary.withValues(alpha: 0.9)),
          const SizedBox(width: PsSpacing.md),
          Expanded(
            child: Text(
              l10n.searchHintPanel,
              style: theme.textTheme.bodySmall?.copyWith(
                color: PsColors.onSurfaceVariant,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
