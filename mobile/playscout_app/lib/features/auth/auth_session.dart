import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../app/router.dart';
import '../home_discover/data/venues_nearby_repository.dart';
import 'data/auth_api_repository.dart';
import 'data/auth_token_store.dart';
import 'models/pending_auth_intent.dart';
import 'models/token_bundle.dart';

/// Global auth + guest session; drives `GoRouter` refresh and token persistence.
class AuthSession extends ChangeNotifier {
  AuthSession({
    required SharedPreferences prefs,
    String? apiBaseUrl,
    http.Client? httpClient,
    GoogleSignIn? googleSignIn,
  })  : _tokenStore = AuthTokenStore(prefs),
        _pendingStore = PendingAuthIntentStore(prefs),
        _api = AuthApiRepository(
          httpClient: httpClient,
          apiBaseUrl: apiBaseUrl ?? VenuesNearbyRepository.defaultApiBase(),
        ) {
    if (googleSignIn != null) {
      _google = googleSignIn;
    } else if (kIsWeb) {
      const webClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');
      _google = webClientId.isEmpty
          ? null
          : GoogleSignIn(
              clientId: webClientId,
              scopes: const ['email', 'openid'],
            );
    } else {
      _google = GoogleSignIn(
        scopes: const ['email', 'openid'],
      );
    }
  }

  final AuthTokenStore _tokenStore;
  final PendingAuthIntentStore _pendingStore;
  final AuthApiRepository _api;
  late final GoogleSignIn? _google;

  TokenBundle? _tokens;

  TokenBundle? get tokens => _tokens;

  bool get isAuthenticated => _tokens != null;

  /// Signed-in full account (not guest JWT).
  bool get hasMemberSession => _tokens != null && !_tokens!.isGuest;

  /// Guest JWT from `/auth/guest`.
  bool get isGuestSession => _tokens != null && _tokens!.isGuest;

  String? get bearerAccessToken => _tokens?.accessToken;

  Future<void> restore() async {
    _tokens = await _tokenStore.load();
    notifyListeners();
  }

  Future<void> applyTokens(TokenBundle bundle) async {
    _tokens = bundle;
    await _tokenStore.save(bundle);
    notifyListeners();
  }

  Future<void> signOut() async {
    _tokens = null;
    await _tokenStore.clear();
    try {
      await _google?.signOut();
    } catch (_) {}
    notifyListeners();
  }

  Future<void> armResumeIntent(PendingAuthIntent intent) => _pendingStore.setIntent(intent);

  Future<void> clearResumeIntent() => _pendingStore.clear();

  Future<PendingAuthIntent?> peekResumeIntent() => _pendingStore.peek();

  /// Returns a usable bearer access token, refreshing with `/auth/refresh` shortly before expiry.
  Future<String?> bearerForApi() async {
    final bundle = _tokens;
    if (bundle == null) return null;
    final now = DateTime.now().toUtc();
    if (bundle.accessTokenExpiresAtUtc.isAfter(now.add(const Duration(seconds: 45)))) {
      return bundle.accessToken;
    }
    final ok = await tryRefreshTokens();
    if (!ok) return null;
    return _tokens?.accessToken;
  }

  /// Uses the stored refresh token to rotate JWTs. On failure, signs out.
  Future<bool> tryRefreshTokens() async {
    final t = _tokens;
    if (t == null) return false;
    try {
      final next = await _api.refresh(t.refreshToken);
      await applyTokens(next);
      return true;
    } catch (_) {
      await signOut();
      return false;
    }
  }

  /// Consumes the single pending intent after auth: favorite resume, then route targets.
  Future<PendingIntentDispatch> dispatchPendingIntent(
    GoRouter router, {
    Future<void> Function(String venueId)? onFavoriteResume,
  }) async {
    final intent = await _pendingStore.consume();
    if (intent == null) return const PendingIntentDispatch(navigated: false);
    switch (intent.kind) {
      case PendingAuthIntentKind.toggleFavoriteVenue:
        final id = intent.venueId;
        if (id != null && hasMemberSession && onFavoriteResume != null) {
          try {
            await onFavoriteResume(id);
          } catch (_) {}
        }
        return const PendingIntentDispatch(navigated: false);
      case PendingAuthIntentKind.writeReviewVenue:
        final id = intent.venueId;
        if (id != null && id.isNotEmpty && hasMemberSession) {
          await _openWriteReviewRoute(router, id);
          return const PendingIntentDispatch(navigated: true);
        }
        return const PendingIntentDispatch(navigated: false);
      case PendingAuthIntentKind.suggestPlaceForm:
        if (hasMemberSession) {
          await _openSuggestFormRoute(router);
          return const PendingIntentDispatch(navigated: true);
        }
        return const PendingIntentDispatch(navigated: false);
      case PendingAuthIntentKind.openFavorites:
        router.go(PsRoutes.favorites);
        return const PendingIntentDispatch(navigated: true);
      case PendingAuthIntentKind.openPath:
        final p = intent.path;
        if (p != null && p.isNotEmpty) {
          router.go(p);
          return const PendingIntentDispatch(navigated: true);
        }
        return const PendingIntentDispatch(navigated: false);
    }
  }

  /// When resuming from login/register/forgot, replace that route so venue (or home) stays underneath.
  static bool _replaceCurrentRouteForMemberResume(GoRouter router) {
    final path = router.state.matchedLocation;
    return path.startsWith(PsRoutes.authLogin) ||
        path.startsWith(PsRoutes.authRegister) ||
        path.startsWith(PsRoutes.authForgot);
  }

  static Future<void> _openWriteReviewRoute(GoRouter router, String venueId) async {
    final target = '${PsRoutes.writeReview}/${Uri.encodeComponent(venueId)}';
    if (_replaceCurrentRouteForMemberResume(router)) {
      router.pushReplacement(target);
    } else {
      router.push(target);
    }
  }

  static Future<void> _openSuggestFormRoute(GoRouter router) async {
    if (_replaceCurrentRouteForMemberResume(router)) {
      router.pushReplacement(PsRoutes.suggestForm);
    } else {
      router.push(PsRoutes.suggestForm);
    }
  }

  Future<TokenBundle> loginEmailPassword({
    required String email,
    required String password,
  }) =>
      _api.login(email: email, password: password);

  Future<TokenBundle> register({
    required String email,
    required String password,
    String? displayName,
  }) =>
      _api.register(email: email, password: password, displayName: displayName);

  Future<TokenBundle> continueAsGuest() => _api.guest();

  Future<TokenBundle> signInWithGoogleIdToken() async {
    final google = _google;
    if (google == null) {
      throw StateError('google_sign_in_unconfigured_web');
    }
    final account = await google.signIn();
    if (account == null) {
      throw StateError('cancelled');
    }
    final auth = await account.authentication;
    final idToken = auth.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw StateError('missing_id_token');
    }
    return _api.google(idToken);
  }

  Future<TokenBundle> signInWithAppleTokens() async {
    if (kIsWeb) {
      throw UnsupportedError('web');
    }
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );
    final identity = credential.identityToken;
    if (identity == null || identity.isEmpty) {
      throw StateError('missing_identity_token');
    }
    return _api.apple(
      identityToken: identity,
      authorizationCode: credential.authorizationCode,
      userIdentifier: credential.userIdentifier,
    );
  }
}
