import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:playscout_app/l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/favorites_scope.dart';
import '../../app/venue_share.dart';
import '../../app/play_scout_route_observer.dart';
import '../../app/router.dart';
import '../auth/models/pending_auth_intent.dart';
import '../auth/protected_member_action.dart';
import '../favorites/favorite_actions.dart';
import '../../design_system/design_tokens.dart';
import 'formatting/venue_detail_distance.dart';
import 'venue_detail_controller.dart';
import 'venue_detail_state.dart';
import 'widgets/venue_detail_amenities_grid.dart';
import 'widgets/venue_detail_description.dart';
import 'widgets/venue_detail_hero_carousel.dart';
import 'widgets/venue_detail_map_preview.dart';
import 'widgets/venue_detail_quick_decision_chips.dart';
import 'widgets/venue_detail_reviews_preview.dart';
import 'widgets/venue_detail_sticky_cta.dart';
import 'widgets/venue_detail_title_stats.dart';
import 'widgets/venue_detail_top_nav.dart';
import 'widgets/venue_detail_trust_cards.dart';

/// Venue Detail — Little Explorers Hub (Stitch `b2469601f5e942748910a4f71f500e96`). Body only; shell nav unchanged.
class VenueDetailScreen extends StatefulWidget {
  const VenueDetailScreen({
    super.key,
    required this.venueId,
    VenueDetailController? controller,
  }) : _controllerOverride = controller;

  final String venueId;
  final VenueDetailController? _controllerOverride;

  @override
  State<VenueDetailScreen> createState() => _VenueDetailScreenState();
}

class _VenueDetailScreenState extends State<VenueDetailScreen> with RouteAware {
  late final VenueDetailController _controller =
      widget._controllerOverride ?? VenueDetailController(venueId: widget.venueId);

  @override
  void initState() {
    super.initState();
    _controller.load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute<void>) {
      playScoutRouteObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    playScoutRouteObserver.unsubscribe(this);
    if (widget._controllerOverride == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  void didPopNext() {
    _controller.reloadReviewsIfReady();
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.paddingOf(context).top;
    final bottomPad = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      backgroundColor: PsColors.background,
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          final state = _controller.state;
          final l10n = AppLocalizations.of(context);
          return switch (state) {
            VenueDetailLoading() => const Center(
                child: SizedBox(
                  width: 36,
                  height: 36,
                  child: CircularProgressIndicator(strokeWidth: 3, color: PsColors.primary),
                ),
              ),
            VenueDetailError(:final message, :final isNotFound) => _ErrorBody(
                message: message,
                isNotFound: isNotFound,
                onRetry: _controller.load,
                onBack: () => _popOrHome(context),
              ),
            VenueDetailReady(:final venue, :final reviews, :final distanceMeters) => Stack(
                fit: StackFit.expand,
                children: [
                  SingleChildScrollView(
                    padding: EdgeInsets.only(
                      left: 0,
                      top: topPad + 64 + 16,
                      right: 0,
                      bottom: bottomPad + 128 + PsSpacing.lg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: PsSpacing.md),
                          child: VenueDetailHeroCarousel(images: venue.images),
                        ),
                        const SizedBox(height: PsSpacing.xl),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: PsSpacing.lg),
                          child: VenueDetailTitleStats(
                            name: venue.name,
                            distanceLine: venueDetailDistanceLine(l10n, distanceMeters),
                            reviewCountLabel: l10n.venueReviewCount(venue.reviewCount),
                            averageRating: venue.averageRating,
                          ),
                        ),
                        const SizedBox(height: PsSpacing.lg),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: PsSpacing.lg),
                          child: VenueDetailQuickDecisionChips(
                            ageChipLabel: ageChipFromMonths(l10n, venue.minAgeMonths, venue.maxAgeMonths),
                            showIndoor: venue.featureTypes.contains(3),
                            showOutdoor: venue.featureTypes.contains(4) && !venue.featureTypes.contains(3),
                          ),
                        ),
                        const SizedBox(height: PsSpacing.xl),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: PsSpacing.lg),
                          child: VenueDetailTrustCards(
                            hasPlaySupervisor: venue.hasPlaySupervisor,
                            allowsChildDropOff: venue.allowsChildDropOff,
                          ),
                        ),
                        if (venue.description != null && venue.description!.trim().isNotEmpty) ...[
                          const SizedBox(height: PsSpacing.xl),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: PsSpacing.lg),
                            child: VenueDetailDescription(text: venue.description!.trim()),
                          ),
                        ],
                        const SizedBox(height: PsSpacing.xl),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: PsSpacing.lg),
                          child: VenueDetailAmenitiesGrid(
                            sectionTitle: l10n.venueAmenitiesSectionTitle,
                            featureTypes: venue.featureTypes,
                          ),
                        ),
                        const SizedBox(height: 48),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: PsSpacing.lg),
                          child: VenueDetailMapPreview(
                            openInMapsLabel: l10n.venueOpenInMaps,
                            latitude: venue.latitude,
                            longitude: venue.longitude,
                          ),
                        ),
                        const SizedBox(height: 48),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: PsSpacing.lg),
                          child: VenueDetailReviewsPreview(
                            reviews: reviews,
                            onViewAll: () => context.push('${PsRoutes.reviews}/${venue.id}'),
                            onWriteReview: () async {
                              await playScoutRequireFullMember(
                                context,
                                resumeIfGuest: PendingAuthIntent.writeReview(venue.id),
                                whenMember: () async {
                                  if (context.mounted) {
                                    await context.push('${PsRoutes.writeReview}/${venue.id}');
                                  }
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                  Positioned(
                    top: topPad,
                    left: 0,
                    right: 0,
                    child: ListenableBuilder(
                      listenable: FavoritesScope.of(context),
                      builder: (context, _) {
                        final catalog = FavoritesScope.of(context);
                        final thumb = venue.images.isNotEmpty ? venue.images.first.url : null;
                        return VenueDetailTopNav(
                          title: l10n.venueDetailScreenTitle,
                          onBack: () => _popOrHome(context),
                          favoriteSelected: catalog.isFavorite(venue.id),
                          favoriteBusy: catalog.isLoading(venue.id),
                          onFavoriteTap: () async {
                            try {
                              await playScoutFavoriteTap(
                                context,
                                venueId: venue.id,
                                venueName: venue.name,
                                primaryImageUrl: thumb,
                              );
                            } catch (_) {
                              if (context.mounted) {
                                _snack(l10n.favoriteCouldNotUpdate);
                              }
                            }
                          },
                          onShareTap: () async {
                            final url = playScoutVenueShareUrl(venue.id);
                            final text = l10n.shareVenueBody(venue.name, url);
                            await Share.share(text, subject: venue.name);
                          },
                        );
                      },
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: SafeArea(
                      top: false,
                      child: VenueDetailStickyCta(
                        getDirectionsLabel: l10n.venueGetDirectionsCta,
                        latitude: venue.latitude,
                        longitude: venue.longitude,
                      ),
                    ),
                  ),
                ],
              ),
          };
        },
      ),
    );
  }

  void _popOrHome(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(PsRoutes.home);
    }
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({
    required this.message,
    required this.isNotFound,
    required this.onRetry,
    required this.onBack,
  });

  final String message;
  final bool isNotFound;
  final VoidCallback onRetry;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(PsSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_rounded),
                color: PsColors.primary,
              ),
            ),
            const Spacer(),
            Icon(
              isNotFound ? Icons.search_off_rounded : Icons.cloud_off_outlined,
              size: 48,
              color: PsColors.error.withValues(alpha: 0.85),
            ),
            const SizedBox(height: PsSpacing.md),
            Text(
              isNotFound ? 'Venue not found' : 'Something went wrong',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: PsSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: PsColors.onSurfaceVariant),
            ),
            const SizedBox(height: PsSpacing.lg),
            if (!isNotFound)
              FilledButton(
                onPressed: onRetry,
                child: Text(AppLocalizations.of(context).retry),
              ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
