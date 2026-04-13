import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/locale_controller.dart';
import 'app/router.dart';
import 'features/auth/auth_session.dart';
import 'features/auth/data/auth_aware_http_client.dart';
import 'features/favorites/data/favorites_repository.dart';
import 'features/favorites/favorites_store.dart';
import 'features/home_discover/data/venues_nearby_repository.dart';
import 'features/suggestions/data/suggestions_repository.dart';
import 'features/venue_detail/data/reviews_write_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final base = VenuesNearbyRepository.defaultApiBase();
  final authSession = AuthSession(prefs: prefs, apiBaseUrl: base);
  await authSession.restore();
  final localeController = LocaleController(prefs);
  await localeController.restore();
  final inner = http.Client();
  final authHttp = AuthAwareHttpClient(authSession, inner);
  final favoritesRepo = FavoritesRepository(httpClient: authHttp, apiBaseUrl: base);
  final favoritesStore = FavoritesStore(
    authSession: authSession,
    repository: favoritesRepo,
    localeController: localeController,
  );
  final reviewsWriteRepo = ReviewsWriteRepository(httpClient: authHttp, apiBaseUrl: base);
  final suggestionsRepo = SuggestionsRepository(httpClient: authHttp, apiBaseUrl: base);
  final router = buildPlayScoutRouter(authSession);
  runApp(PlayScoutApp(
    router: router,
    authSession: authSession,
    favoritesStore: favoritesStore,
    reviewsWriteRepository: reviewsWriteRepo,
    suggestionsRepository: suggestionsRepo,
    localeController: localeController,
  ));
}
