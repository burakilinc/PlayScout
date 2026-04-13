import 'package:flutter/material.dart';
import 'package:playscout_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_criteria_scope.dart';
import '../../app/favorites_scope.dart';
import '../../app/router.dart';
import '../favorites/favorite_actions.dart';
import '../../design_system/design_tokens.dart';
import '../filter_options/models/venue_nearby_criteria.dart';
import '../home_discover/data/user_location_source.dart' show DevUserLocationSource, UserLocationSource;
import '../home_discover/data/venues_nearby_repository.dart';
import '../home_discover/models/user_location.dart';
import '../home_discover/models/venue_summary.dart';
import 'interactive_park_map_controller.dart';
import 'interactive_park_map_state.dart';
import 'widgets/interactive_map_decorative_background.dart';
import 'widgets/interactive_map_empty_overlay.dart';
import 'widgets/interactive_map_header.dart';
import 'widgets/interactive_map_status_backdrop.dart';
import 'widgets/interactive_map_list_cta.dart';
import 'widgets/interactive_map_my_location_button.dart';
import 'widgets/interactive_map_pin_layer.dart';
import 'widgets/interactive_map_preview_card.dart';
import 'widgets/interactive_map_quick_chips.dart';
import 'widgets/interactive_map_search_filter_row.dart';

/// Stitch `Interactive Park Map` — body only; [PlayScoutShell] provides bottom navigation.
class InteractiveParkMapScreen extends StatefulWidget {
  const InteractiveParkMapScreen({
    super.key,
    VenuesNearbyRepository? repository,
    UserLocationSource? locationSource,
  })  : _repository = repository,
        _locationSource = locationSource;

  final VenuesNearbyRepository? _repository;
  final UserLocationSource? _locationSource;

  @override
  State<InteractiveParkMapScreen> createState() => _InteractiveParkMapScreenState();
}

class _InteractiveParkMapScreenState extends State<InteractiveParkMapScreen> {
  InteractiveParkMapController? _controller;

  InteractiveParkMapController _ensureController(BuildContext context) {
    return _controller ??= InteractiveParkMapController(
      repository: widget._repository ?? VenuesNearbyRepository(),
      locationSource: widget._locationSource ?? DevUserLocationSource(),
      appCriteria: AppCriteriaScope.of(context),
    )..load();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _openFilter() async {
    final c = _ensureController(context);
    final r = await context.push<VenueNearbyCriteria>(
      PsRoutes.filter,
      extra: c.criteriaForFilter,
    );
    if (!mounted || r == null) return;
    c.applyFilterCriteria(r);
  }

  Future<void> _openSearch() async {
    await context.push(PsRoutes.search);
  }

  Future<void> _openList(List<VenueSummary> venues) async {
    await context.push(PsRoutes.mapList, extra: venues);
  }

  @override
  Widget build(BuildContext context) {
    final controller = _ensureController(context);
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: PsColors.surface,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SafeArea(
            bottom: false,
            child: InteractiveMapHeader(
              onTune: _openFilter,
            ),
          ),
          Expanded(
            child: ListenableBuilder(
              listenable: controller,
              builder: (context, _) {
                final s = controller.state;
                return switch (s) {
                  InteractiveParkMapLoading() => InteractiveMapStatusBackdrop(
                      strength: 0.42,
                      child: const Center(
                        child: CircularProgressIndicator(color: PsColors.primary),
                      ),
                    ),
                  InteractiveParkMapError() => InteractiveMapStatusBackdrop(
                      strength: 0.45,
                      child: _ErrorOverlayBody(
                        onRetry: () => controller.load(),
                      ),
                    ),
                  final InteractiveParkMapEmpty e => _MapStage(
                      location: e.location,
                      venues: const [],
                      selectedVenueId: null,
                      controller: controller,
                      onSearchTap: _openSearch,
                      onFilterTap: _openFilter,
                      onListTap: () => _openList(const []),
                      emptyTitle: l10n.mapEmptyTitle,
                      emptySubtitle:
                          l10n.mapEmptySubtitle,
                    ),
                  final InteractiveParkMapReady r => _MapStage(
                      location: r.location,
                      venues: r.venues,
                      selectedVenueId: r.selectedVenueId,
                      controller: controller,
                      onSearchTap: _openSearch,
                      onFilterTap: _openFilter,
                      onListTap: () => _openList(r.venues),
                      emptyTitle: null,
                      emptySubtitle: null,
                    ),
                };
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorOverlayBody extends StatelessWidget {
  const _ErrorOverlayBody({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(PsSpacing.lg),
        child: Material(
          color: PsColors.surfaceContainerLowest.withValues(alpha: 0.96),
          elevation: 4,
          shadowColor: const Color(0xFF36392B).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(PsRadii.lg),
          child: Padding(
            padding: const EdgeInsets.all(PsSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_off_rounded, size: 48, color: PsColors.onSurfaceVariant.withValues(alpha: 0.5)),
                const SizedBox(height: PsSpacing.md),
                Text(
                  l10n.errorSomethingWrong,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(color: PsColors.onSurfaceVariant),
                ),
                const SizedBox(height: PsSpacing.lg),
                FilledButton(
                  onPressed: onRetry,
                  style: FilledButton.styleFrom(
                    backgroundColor: PsColors.primary,
                    foregroundColor: PsColors.onPrimary,
                  ),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MapStage extends StatelessWidget {
  const _MapStage({
    required this.location,
    required this.venues,
    required this.selectedVenueId,
    required this.controller,
    required this.onSearchTap,
    required this.onFilterTap,
    required this.onListTap,
    required this.emptyTitle,
    required this.emptySubtitle,
  });

  final UserLocation location;
  final List<VenueSummary> venues;
  final String? selectedVenueId;
  final InteractiveParkMapController controller;
  final VoidCallback onSearchTap;
  final VoidCallback onFilterTap;
  final VoidCallback onListTap;
  final String? emptyTitle;
  final String? emptySubtitle;

  @override
  Widget build(BuildContext context) {
    final bottomPad = 96 + MediaQuery.paddingOf(context).bottom;
    return Stack(
      fit: StackFit.expand,
      children: [
        Stack(
          fit: StackFit.expand,
          children: [
            const InteractiveMapDecorativeBackground(),
            if (venues.isNotEmpty)
              InteractiveMapPinLayer(
                location: location,
                venues: venues,
                selectedVenueId: selectedVenueId,
                onSelectVenue: controller.selectVenue,
                onBackdropTap: controller.deselectVenue,
              )
            else
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: controller.deselectVenue,
                  child: const ColoredBox(color: Colors.transparent),
                ),
              ),
          ],
        ),
        Positioned.fill(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(PsSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InteractiveMapSearchFilterRow(
                    location: location,
                    onSearchTap: onSearchTap,
                    onFilterTap: onFilterTap,
                  ),
                  const SizedBox(height: PsSpacing.md),
                  InteractiveMapQuickChips(
                    indoorSelected: controller.indoorChip,
                    nearbySelected: controller.nearbyChip,
                    toddlerSelected: controller.toddlerChip,
                    onIndoor: controller.setIndoorChip,
                    onNearby: controller.setNearbyChip,
                    onToddler: controller.setToddlerChip,
                  ),
                  if (emptyTitle != null) ...[
                    const Spacer(),
                    InteractiveMapEmptyOverlay(
                      title: emptyTitle!,
                      subtitle: emptySubtitle,
                    ),
                  ],
                  const Spacer(),
                  InteractiveMapMyLocationButton(
                    onPressed: () => controller.refreshLocation(),
                  ),
                  const SizedBox(height: PsSpacing.md),
                  if (selectedVenueId != null && venues.isNotEmpty)
                    Builder(
                      builder: (context) {
                        VenueSummary? match;
                        for (final x in venues) {
                          if (x.id == selectedVenueId) match = x;
                        }
                        if (match == null) return const SizedBox.shrink();
                        final selected = match;
                        return ListenableBuilder(
                          listenable: FavoritesScope.of(context),
                          builder: (context, _) {
                            final catalog = FavoritesScope.of(context);
                            return InteractiveMapPreviewCard(
                              venue: selected,
                              isFavorite: catalog.isFavorite(selected.id),
                              favoriteInProgress: catalog.isLoading(selected.id),
                              onFavoriteTap: () async {
                                try {
                                  await playScoutFavoriteTap(
                                    context,
                                    venueId: selected.id,
                                    venueName: selected.name,
                                    primaryImageUrl: selected.primaryImageUrl,
                                  );
                                } catch (_) {}
                              },
                              onTap: () => context.push('${PsRoutes.venue}/${selected.id}'),
                            );
                          },
                        );
                      },
                    ),
                  const SizedBox(height: PsSpacing.md),
                  Padding(
                    padding: EdgeInsets.only(bottom: bottomPad),
                    child: InteractiveMapListCta(onPressed: onListTap),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
