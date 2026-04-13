import 'package:flutter/material.dart';
import 'package:playscout_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_criteria_scope.dart';
import '../../app/auth_scope.dart';
import '../../app/language_picker_sheet.dart';
import '../../app/router.dart';
import '../../design_system/design_tokens.dart';
import '../filter_options/models/venue_nearby_criteria.dart';
import 'data/events_weekend_repository.dart';
import 'data/user_location_source.dart';
import 'data/venues_nearby_repository.dart';
import 'home_discover_controller.dart';
import 'home_discover_state.dart';
import 'home_discover_strings.dart';
import 'models/venue_summary.dart';
import 'widgets/home_category_orb_row.dart';
import 'widgets/home_discover_headline_block.dart';
import 'widgets/home_discover_top_bar.dart';
import 'widgets/home_gradient_cta_panel.dart';
import 'widgets/home_near_you_section.dart';
import 'widgets/home_search_and_filter_row.dart';
import 'widgets/home_weekend_section.dart';

/// Discover home (Stitch id `home_discover`). Body layout follows Stitch Home & Discover scroll structure.
class HomeDiscoverScreen extends StatefulWidget {
  const HomeDiscoverScreen({
    super.key,
    VenuesNearbyRepository? repository,
    UserLocationSource? locationSource,
    EventsWeekendRepository? eventsRepository,
  })  : _repository = repository,
        _locationSource = locationSource,
        _eventsRepository = eventsRepository;

  final VenuesNearbyRepository? _repository;
  final UserLocationSource? _locationSource;
  final EventsWeekendRepository? _eventsRepository;

  @override
  State<HomeDiscoverScreen> createState() => _HomeDiscoverScreenState();
}

class _HomeDiscoverScreenState extends State<HomeDiscoverScreen> {
  HomeDiscoverController? _controller;

  HomeDiscoverController _ensureController(BuildContext context) {
    return _controller ??= HomeDiscoverController(
      repository: widget._repository ?? VenuesNearbyRepository(),
      locationSource: widget._locationSource ?? DevUserLocationSource(),
      appCriteria: AppCriteriaScope.of(context),
      eventsRepository: widget._eventsRepository,
    )..load();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  String _greetingLine(AppLocalizations l10n) {
    final h = DateTime.now().hour;
    if (h < 12) return l10n.greetingMorning;
    if (h < 17) return l10n.greetingAfternoon;
    return l10n.greetingEvening;
  }

  void _snack(BuildContext context, String text) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final controller = _ensureController(context);
    return KeyedSubtree(
      key: const Key(HomeDiscoverStrings.screenKeyId),
      child: Scaffold(
        backgroundColor: PsColors.background,
        body: SafeArea(
          bottom: false,
          child: ListenableBuilder(
            listenable: controller,
            builder: (context, _) {
              final l10n = AppLocalizations.of(context);
              final state = controller.state;
              final locationLabel = switch (state) {
                HomeDiscoverReady(:final location) => location.displayLabel,
                HomeDiscoverError() => l10n.dashEmDash,
                HomeDiscoverLoading() => '…',
              };

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  HomeDiscoverTopBar(
                    locationLabel: locationLabel,
                    onLocationTap: () => _snack(
                      context,
                      l10n.locationPickerSoon,
                    ),
                    onLanguageTap: () => showLanguagePickerSheet(context),
                    onNotificationsTap: () => _snack(
                      context,
                      l10n.notificationsSoon,
                    ),
                    onAccountTap: () {
                      final auth = AuthScope.of(context);
                      if (!auth.isAuthenticated) {
                        context.push(PsRoutes.authWelcome);
                      } else {
                        context.push(PsRoutes.account);
                      }
                    },
                  ),
                  Expanded(
                    child: switch (state) {
                      HomeDiscoverError(:final message) => _ErrorPane(
                          message: message,
                          onRetry: controller.load,
                        ),
                      HomeDiscoverLoading() => const Center(
                          child: SizedBox(
                            width: 36,
                            height: 36,
                            child: CircularProgressIndicator(strokeWidth: 3, color: PsColors.primary),
                          ),
                        ),
                      HomeDiscoverReady(
                        :final location,
                        :final venues,
                        :final weekendEvents,
                        :final selectedCategory,
                      ) =>
                        RefreshIndicator(
                          color: PsColors.primary,
                          onRefresh: controller.refresh,
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.only(bottom: PsSpacing.xl),
                            children: [
                              const SizedBox(height: PsSpacing.md),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: PsSpacing.lg),
                                child: HomeDiscoverHeadlineBlock(
                                  headline: _greetingLine(l10n),
                                  subline: l10n.whereToToday,
                                  locationLine: location.displayLabel,
                                  onLocationPillTap: () => _snack(
                                    context,
                                    l10n.locationPickerSoon,
                                  ),
                                ),
                              ),
                              const SizedBox(height: PsSpacing.xl),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: PsSpacing.lg),
                                child: HomeSearchAndFilterRow(
                                  onSearchTap: () => context.push(PsRoutes.search),
                                  onFilterTap: () async {
                                    final r = await context.push<VenueNearbyCriteria>(
                                      PsRoutes.filter,
                                      extra: controller.criteriaForFilterUi,
                                    );
                                    if (!context.mounted) return;
                                    if (r != null) controller.applyNearbyCriteria(r);
                                  },
                                ),
                              ),
                              const SizedBox(height: PsSpacing.xl),
                              HomeCategoryOrbRow(
                                selected: selectedCategory,
                                onSelected: controller.selectCategory,
                              ),
                              const SizedBox(height: PsSpacing.xl),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: PsSpacing.lg),
                                child: HomeGradientCtaPanel(
                                  onPressed: () => context.push(PsRoutes.recommendations),
                                ),
                              ),
                              const SizedBox(height: PsSpacing.md),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: PsSpacing.lg),
                                child: OutlinedButton.icon(
                                  onPressed: () => context.push(PsRoutes.suggestEntry),
                                  icon: const Icon(Icons.add_location_alt_outlined, size: 20),
                                  label: Text(l10n.suggestPlaceCta),
                                ),
                              ),
                              const SizedBox(height: PsSpacing.xl),
                              HomeWeekendSection(
                                events: weekendEvents,
                                onEventTap: (e) => context.push('${PsRoutes.eventDetail}/${e.id}'),
                              ),
                              const SizedBox(height: PsSpacing.xl),
                              HomeNearYouSection(
                                venues: venues,
                                onVenueTap: (VenueSummary v) => context.push('${PsRoutes.venue}/${v.id}'),
                                onClearFilters: controller.resetCategoryFilter,
                              ),
                            ],
                          ),
                        ),
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ErrorPane extends StatelessWidget {
  const _ErrorPane({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(PsSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined, size: 48, color: PsColors.error.withValues(alpha: 0.85)),
            const SizedBox(height: PsSpacing.md),
            Text(
              l10n.homeErrorTitle,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: PsSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: PsColors.onSurfaceVariant),
            ),
            const SizedBox(height: PsSpacing.lg),
            FilledButton(onPressed: onRetry, child: Text(l10n.retry)),
          ],
        ),
      ),
    );
  }
}
