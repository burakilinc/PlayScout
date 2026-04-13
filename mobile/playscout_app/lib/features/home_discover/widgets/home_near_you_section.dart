import 'package:flutter/material.dart';

import 'package:playscout_app/l10n/app_localizations.dart';

import '../../../app/favorites_scope.dart';
import '../../../design_system/design_tokens.dart';
import '../../favorites/favorite_actions.dart';
import '../models/venue_summary.dart';
import 'home_near_you_venue_card.dart';

/// Stitch “Near you” heading + vertical venue list + empty state.
class HomeNearYouSection extends StatelessWidget {
  const HomeNearYouSection({
    super.key,
    required this.venues,
    required this.onVenueTap,
    required this.onClearFilters,
  });

  final List<VenueSummary> venues;
  final void Function(VenueSummary venue) onVenueTap;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: PsSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.homeNearYouHeading,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: PsColors.onSurface,
            ),
          ),
          const SizedBox(height: PsSpacing.md),
          if (venues.isEmpty)
            _NearYouEmpty(l10n: l10n, onClearFilters: onClearFilters)
          else
            ListenableBuilder(
              listenable: FavoritesScope.of(context),
              builder: (context, _) {
                final catalog = FavoritesScope.of(context);
                return Column(
                  children: [
                    for (final v in venues)
                      HomeNearYouVenueCard(
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
                        onTap: () => onVenueTap(v),
                      ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

class _NearYouEmpty extends StatelessWidget {
  const _NearYouEmpty({required this.l10n, required this.onClearFilters});

  final AppLocalizations l10n;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: PsSpacing.lg),
      child: Column(
        children: [
          Icon(Icons.search_off_outlined, size: 48, color: PsColors.onSurfaceVariant),
          const SizedBox(height: PsSpacing.md),
          Text(
            l10n.homeEmptyTitle,
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: PsSpacing.sm),
          Text(
            l10n.homeEmptySubtitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: PsColors.onSurfaceVariant),
          ),
          const SizedBox(height: PsSpacing.lg),
          OutlinedButton(
            onPressed: onClearFilters,
            child: Text(l10n.homeShowAllCategories),
          ),
        ],
      ),
    );
  }
}
