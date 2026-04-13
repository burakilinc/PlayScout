import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/auth_scope.dart';
import '../../app/favorites_scope.dart';
import '../../app/router.dart';
import '../auth/models/pending_auth_intent.dart';

/// Guest / anonymous → guest sheet with resume; full member → toggle via [FavoritesCatalog].
Future<void> playScoutFavoriteTap(
  BuildContext context, {
  required String venueId,
  String? venueName,
  String? primaryImageUrl,
}) async {
  final auth = AuthScope.of(context);
  final fav = FavoritesScope.of(context);
  if (auth.hasMemberSession) {
    await fav.toggleFavorite(venueId: venueId, displayName: venueName, primaryImageUrl: primaryImageUrl);
    return;
  }
  if (!context.mounted) return;
  await context.push(PsRoutes.guestPrompt, extra: PendingAuthIntent.toggleFavorite(venueId));
}
