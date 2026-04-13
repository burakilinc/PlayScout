import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:playscout_app/app/app.dart';
import 'package:playscout_app/app/locale_controller.dart';
import 'package:playscout_app/app/router.dart';
import 'package:playscout_app/features/auth/auth_session.dart';
import 'package:playscout_app/features/auth/data/auth_aware_http_client.dart';
import 'package:playscout_app/features/favorites/data/favorites_repository.dart';
import 'package:playscout_app/features/favorites/favorites_catalog.dart';
import 'package:playscout_app/features/home_discover/data/venues_nearby_repository.dart';
import 'package:playscout_app/features/suggestions/data/suggestions_repository.dart';
import 'package:playscout_app/features/venue_detail/data/reviews_write_repository.dart';
import 'package:playscout_app/features/home_discover/home_discover_strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('PlayScoutApp builds', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final base = VenuesNearbyRepository.defaultApiBase();
    final authSession = AuthSession(prefs: prefs, apiBaseUrl: base);
    await authSession.restore();
    final inner = http.Client();
    final authHttp = AuthAwareHttpClient(authSession, inner);
    final favoritesRepo = FavoritesRepository(httpClient: authHttp, apiBaseUrl: base);
    final localeController = LocaleController(prefs);
    await localeController.restore();
    final favoritesCatalog = FavoritesCatalog(
      authSession: authSession,
      repository: favoritesRepo,
      localeController: localeController,
    );
    final reviewsWriteRepo = ReviewsWriteRepository(httpClient: authHttp, apiBaseUrl: base);
    final suggestionsRepo = SuggestionsRepository(httpClient: authHttp, apiBaseUrl: base);
    final router = buildPlayScoutRouter(authSession);
    await tester.pumpWidget(PlayScoutApp(
      router: router,
      authSession: authSession,
      favoritesCatalog: favoritesCatalog,
      reviewsWriteRepository: reviewsWriteRepo,
      suggestionsRepository: suggestionsRepo,
      localeController: localeController,
    ));
    await tester.pump();

    expect(find.byKey(const Key(HomeDiscoverStrings.screenKeyId)), findsOneWidget);
  });
}
