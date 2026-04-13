import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:playscout_app/l10n/app_localizations.dart';

import '../../app/auth_scope.dart';
import '../../app/favorites_scope.dart';
import '../../app/router.dart';
import '../../design_system/design_tokens.dart';
import '../auth/models/pending_auth_intent.dart';
import '../home_discover/data/user_location_source.dart';
import '../home_discover/venue_formatters.dart';
import 'models/favorite_list_item.dart';

/// Favorites tab — guests see sign-in CTA; members see `GET /favorites` data.
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _location = DevUserLocationSource();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshWithLocation());
  }

  Future<void> _refreshWithLocation() async {
    if (!mounted) return;
    final auth = AuthScope.of(context);
    if (!auth.hasMemberSession) return;
    final catalog = FavoritesScope.of(context);
    try {
      final loc = await _location.resolve();
      if (!mounted) return;
      await catalog.refresh(latitude: loc.latitude, longitude: loc.longitude);
    } catch (_) {
      if (mounted) await catalog.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = AuthScope.of(context);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    if (!session.hasMemberSession) {
      return Scaffold(
        backgroundColor: PsColors.background,
        appBar: AppBar(
          title: Text(l10n.favorites),
          actions: [
            TextButton(
              onPressed: () => context.push(PsRoutes.authWelcome),
              child: Text(
                l10n.signIn,
                style: theme.textTheme.labelLarge?.copyWith(color: PsColors.primary),
              ),
            ),
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(PsSpacing.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border_rounded, size: 56, color: PsColors.primary.withValues(alpha: 0.5)),
                  const SizedBox(height: PsSpacing.lg),
                  Text(
                    l10n.savePlacesFamilyLoves,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: PsColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: PsSpacing.md),
                  Text(
                    l10n.favoritesGuestLead,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: PsColors.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: PsSpacing.xl),
                  FilledButton(
                    onPressed: () => context.push(
                      PsRoutes.guestPrompt,
                      extra: PendingAuthIntent.openFavorites,
                    ),
                    child: Text(l10n.guestTitleFavorites),
                  ),
                  const SizedBox(height: PsSpacing.md),
                  OutlinedButton(
                    onPressed: () => context.push(PsRoutes.authWelcome),
                    child: Text(l10n.browseAccountOptions),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: PsColors.background,
      appBar: AppBar(title: Text(l10n.favorites)),
      body: ListenableBuilder(
        listenable: FavoritesScope.of(context),
        builder: (context, _) {
          final catalog = FavoritesScope.of(context);
          final items = catalog.items;
          if (catalog.isLoading && items.isEmpty) {
            return const Center(
              child: SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(strokeWidth: 3, color: PsColors.primary),
              ),
            );
          }
          if (catalog.lastError != null && items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(PsSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.errorSomethingWrong, textAlign: TextAlign.center),
                    const SizedBox(height: PsSpacing.md),
                    FilledButton(onPressed: _refreshWithLocation, child: Text(l10n.retry)),
                  ],
                ),
              ),
            );
          }
          if (items.isEmpty) {
            return RefreshIndicator(
              color: PsColors.primary,
              onRefresh: _refreshWithLocation,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: 120),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: PsSpacing.xl),
                      child: Text(
                        l10n.tapHeartToSave,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            color: PsColors.primary,
            onRefresh: _refreshWithLocation,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: PsSpacing.lg, vertical: PsSpacing.md),
              itemCount: items.length,
              separatorBuilder: (context, _) => const SizedBox(height: PsSpacing.md),
              itemBuilder: (context, i) => _FavoriteVenueTile(
                item: items[i],
                onOpen: () => context.push('${PsRoutes.venue}/${items[i].venueId}'),
                onRemove: () async {
                  try {
                    await catalog.removeFavorite(items[i].venueId);
                  } catch (_) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.couldNotRemoveFavorite)),
                      );
                    }
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FavoriteVenueTile extends StatelessWidget {
  const _FavoriteVenueTile({
    required this.item,
    required this.onOpen,
    required this.onRemove,
  });

  final FavoriteListItem item;
  final VoidCallback onOpen;
  final Future<void> Function() onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final dist = item.distanceMeters != null ? VenueFormatters.distanceMeters(l10n, item.distanceMeters!) : null;
    return Material(
      color: PsColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(PsRadii.md),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(PsSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(PsRadii.sm),
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: item.primaryImageUrl != null && item.primaryImageUrl!.isNotEmpty
                      ? Image.network(
                          item.primaryImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => ColoredBox(
                            color: PsColors.surfaceContainerHigh,
                            child: Icon(Icons.park_rounded, color: PsColors.primary.withValues(alpha: 0.35)),
                          ),
                        )
                      : ColoredBox(
                          color: PsColors.surfaceContainerHigh,
                          child: Icon(Icons.park_rounded, color: PsColors.primary.withValues(alpha: 0.35)),
                        ),
                ),
              ),
              const SizedBox(width: PsSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.venueName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: PsColors.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (dist != null) ...[
                      const SizedBox(height: PsSpacing.xs),
                      Text(
                        dist,
                        style: theme.textTheme.bodySmall?.copyWith(color: PsColors.onSurfaceVariant),
                      ),
                    ],
                    if (item.averageRating != null) ...[
                      const SizedBox(height: PsSpacing.xs),
                      Text(
                        VenueFormatters.ratingLine(l10n, locale, item.averageRating, item.reviewCount),
                        style: theme.textTheme.bodySmall?.copyWith(color: PsColors.onSurfaceVariant),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                tooltip: l10n.removeFromFavorites,
                onPressed: () => onRemove(),
                icon: const Icon(Icons.favorite_rounded, color: PsColors.error),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
