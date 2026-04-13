import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:playscout_app/l10n/app_localizations.dart';

import '../../app/app_criteria_controller.dart';
import '../../app/app_criteria_scope.dart';
import '../../app/favorites_scope.dart';
import '../../app/router.dart';
import '../favorites/favorite_actions.dart';
import '../../design_system/design_tokens.dart';
import '../filter_options/models/venue_nearby_criteria.dart';
import '../home_discover/data/user_location_source.dart';
import '../home_discover/data/venues_nearby_repository.dart';
import '../home_discover/models/venue_summary.dart';
import 'logic/search_venue_query.dart';
import 'models/search_flow_args.dart';
import 'widgets/search_filter_chips_row.dart';
import 'widgets/search_result_venue_card.dart';

/// Stitch `search_results` — distinct header, pill search, shared chips, venue list.
class SearchResultsScreen extends StatefulWidget {
  const SearchResultsScreen({super.key, required this.initialArgs});

  final SearchFlowArgs initialArgs;

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  late SearchFlowArgs _args;
  late final TextEditingController _field;
  final VenuesNearbyRepository _repo = VenuesNearbyRepository();
  final UserLocationSource _location = DevUserLocationSource();
  AppCriteriaController? _appCriteria;

  bool _loading = true;
  bool _hasError = false;
  List<VenueSummary> _venues = const [];
  bool _presentingEmpty = false;

  @override
  void initState() {
    super.initState();
    _args = widget.initialArgs;
    _field = TextEditingController(text: _args.query);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _appCriteria = AppCriteriaScope.of(context);
  }

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _hasError = false;
    });
    try {
      final loc = await _location.resolve();
      if (!mounted) return;
      final app = _appCriteria!.criteria;
      final filter = effectiveDiscoverFilter(app, indoorChip: _args.indoorChip);
      final radius = effectiveRadiusMeters(app, nearbyChip: _args.nearbyChip);
      final childAge = effectiveChildAgeMonths(app, age05Chip: _args.age05Chip);
      final raw = await _repo.fetchNearby(
        location: loc,
        filter: filter,
        radiusMeters: radius,
        childAgeMonths: childAge,
      );
      final filtered = filterVenuesByName(raw, _args.query);
      if (!mounted) return;
      setState(() {
        _loading = false;
        _venues = filtered;
      });
      if (filtered.isEmpty) {
        await _presentEmptyFlow();
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _hasError = true;
      });
    }
  }

  Future<void> _presentEmptyFlow() async {
    if (!mounted || _presentingEmpty) return;
    _presentingEmpty = true;
    final r = await context.push<bool?>(
      PsRoutes.searchEmpty,
      extra: _args,
    );
    _presentingEmpty = false;
    if (!mounted) return;
    if (r == true) {
      setState(() {
        _args = _args.copyWith(
          nearbyChip: false,
          freeChip: false,
          indoorChip: false,
          age05Chip: false,
        );
      });
      await _load();
    }
  }

  Future<void> _openFilter() async {
    final app = AppCriteriaScope.of(context);
    final r = await context.push<VenueNearbyCriteria>(
      PsRoutes.filter,
      extra: app.criteria,
    );
    if (!mounted || r == null) return;
    app.setCriteria(r);
    await _load();
  }

  void _submitQuery() {
    setState(() {
      _args = _args.copyWith(query: _field.text.trim());
    });
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: PsColors.surfaceContainerLow,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(PsSpacing.xs, PsSpacing.sm, PsSpacing.sm, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    color: PsColors.onSurface,
                  ),
                  Expanded(
                    child: Text(
                      l10n.search,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: PsColors.onSurface,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _openFilter,
                    icon: const Icon(Icons.tune_rounded),
                    color: PsColors.primary,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(PsSpacing.lg, PsSpacing.sm, PsSpacing.lg, 0),
              child: Material(
                color: PsColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(PsRadii.xl),
                child: TextField(
                  controller: _field,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _submitQuery(),
                  decoration: InputDecoration(
                    hintText: l10n.search,
                    prefixIcon: const Icon(Icons.search_rounded, color: PsColors.primary),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: PsSpacing.sm, vertical: PsSpacing.md),
                  ),
                ),
              ),
            ),
            const SizedBox(height: PsSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: PsSpacing.lg),
              child: SearchFilterChipsRow(
                nearbySelected: _args.nearbyChip,
                freeSelected: _args.freeChip,
                indoorSelected: _args.indoorChip,
                age05Selected: _args.age05Chip,
                onNearby: (v) {
                  setState(() => _args = _args.copyWith(nearbyChip: v));
                  _load();
                },
                onFree: (v) {
                  setState(() => _args = _args.copyWith(freeChip: v));
                },
                onIndoor: (v) {
                  setState(() => _args = _args.copyWith(indoorChip: v));
                  _load();
                },
                onAge05: (v) {
                  setState(() => _args = _args.copyWith(age05Chip: v));
                  _load();
                },
              ),
            ),
            const SizedBox(height: PsSpacing.md),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: PsSpacing.lg),
                child: _buildBody(theme),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    if (_loading) {
      return const Center(
        child: SizedBox(
          width: 36,
          height: 36,
          child: CircularProgressIndicator(strokeWidth: 3, color: PsColors.primary),
        ),
      );
    }
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined, size: 48, color: PsColors.error.withValues(alpha: 0.85)),
            const SizedBox(height: PsSpacing.md),
            Text(
              l10n.searchSomethingWrong,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: PsSpacing.lg),
            FilledButton(onPressed: _load, child: Text(l10n.retry)),
          ],
        ),
      );
    }
    if (_venues.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(PsSpacing.lg),
          child: Text(
            l10n.searchNoVenuesMatch,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: PsColors.onSurfaceVariant, height: 1.35),
          ),
        ),
      );
    }
    return ListenableBuilder(
      listenable: FavoritesScope.of(context),
      builder: (context, _) {
        final catalog = FavoritesScope.of(context);
        return ListView.separated(
          itemCount: _venues.length,
          separatorBuilder: (context, _) => const SizedBox(height: PsSpacing.md),
          itemBuilder: (context, i) {
            final v = _venues[i];
            return SearchResultVenueCard(
              venue: v,
              isFavorite: catalog.isFavorite(v.id),
              onFavoriteTap: () async {
                try {
                  await playScoutFavoriteTap(
                    context,
                    venueId: v.id,
                    venueName: v.name,
                    primaryImageUrl: v.primaryImageUrl,
                  );
                } catch (_) {}
              },
              onTap: () => context.push('${PsRoutes.venue}/${v.id}'),
            );
          },
        );
      },
    );
  }
}
