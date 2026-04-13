import 'package:flutter/foundation.dart';

import '../../app/locale_controller.dart';
import '../../l10n/app_localizations.dart';
import '../auth/auth_session.dart';
import 'data/favorites_repository.dart';
import 'favorite_venue_ids.dart';
import 'models/favorite_list_item.dart';

String _normVenueId(String id) => FavoriteVenueIds.canonical(id);

/// In-memory favorites index + optimistic mutations for the signed-in member.
class FavoritesCatalog extends ChangeNotifier {
  FavoritesCatalog({
    required AuthSession authSession,
    required FavoritesRepository repository,
    required LocaleController localeController,
  })  : _auth = authSession,
        _repo = repository,
        _locale = localeController {
    _auth.addListener(_onAuthSessionChanged);
    _onAuthSessionChanged();
  }

  final AuthSession _auth;
  final FavoritesRepository _repo;
  final LocaleController _locale;

  final Map<String, FavoriteListItem> _byVenueId = {};
  bool _loading = false;
  String? _lastError;
  bool _hadMemberSession = false;

  bool get isLoading => _loading;
  String? get lastError => _lastError;

  List<FavoriteListItem> get items {
    final list = _byVenueId.values.toList();
    list.sort((a, b) => b.favoritedAtUtc.compareTo(a.favoritedAtUtc));
    return list;
  }

  bool isFavorite(String venueId) => _byVenueId.containsKey(_normVenueId(venueId));

  void _onAuthSessionChanged() {
    final member = _auth.hasMemberSession;
    if (!member) {
      _hadMemberSession = false;
      if (_byVenueId.isNotEmpty) _byVenueId.clear();
      _lastError = null;
      notifyListeners();
      return;
    }
    if (!_hadMemberSession) {
      _hadMemberSession = true;
      // ignore: discarded_futures
      refresh();
    }
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuthSessionChanged);
    super.dispose();
  }

  Future<void> refresh({double? latitude, double? longitude}) async {
    if (!_auth.hasMemberSession) return;
    _loading = true;
    _lastError = null;
    notifyListeners();
    try {
      final list = await _repoWith401Retry(() => _repo.list(latitude: latitude, longitude: longitude));
      _byVenueId
        ..clear()
        ..addEntries(list.map((e) => MapEntry(_normVenueId(e.venueId), e)));
    } catch (e) {
      _lastError = '$e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<T> _repoWith401Retry<T>(Future<T> Function() fn) async {
    try {
      return await fn();
    } on FavoritesUnauthorizedException {
      final ok = await _auth.tryRefreshTokens();
      if (!ok) rethrow;
      return await fn();
    }
  }

  /// Optimistic add; rolls back on failure.
  Future<void> addFavorite({
    required String venueId,
    String? displayName,
    String? primaryImageUrl,
  }) async {
    if (!_auth.hasMemberSession) return;
    final key = _normVenueId(venueId);
    if (_byVenueId.containsKey(key)) return;

    final optimistic = FavoriteListItem(
      favoriteId: 'pending-$key',
      venueId: key,
      venueName: displayName ??
          lookupAppLocalizations(_locale.resolvedLocale).favoritesOptimisticVenueName,
      primaryImageUrl: primaryImageUrl,
      distanceMeters: null,
      averageRating: null,
      reviewCount: 0,
      minAgeMonths: null,
      maxAgeMonths: null,
      hasPlaySupervisor: false,
      allowsChildDropOff: false,
      favoritedAtUtc: DateTime.now().toUtc(),
    );
    _byVenueId[key] = optimistic;
    notifyListeners();

    try {
      final res = await _repoWith401Retry(() => _repo.add(venueId));
      final serverKey = _normVenueId(res.venueId);
      if (serverKey != key) {
        _byVenueId.remove(key);
      }
      _byVenueId[serverKey] = FavoriteListItem(
        favoriteId: res.favoriteId,
        venueId: serverKey,
        venueName: optimistic.venueName,
        primaryImageUrl: optimistic.primaryImageUrl,
        distanceMeters: null,
        averageRating: null,
        reviewCount: 0,
        minAgeMonths: null,
        maxAgeMonths: null,
        hasPlaySupervisor: false,
        allowsChildDropOff: false,
        favoritedAtUtc: optimistic.favoritedAtUtc,
      );
      notifyListeners();
    } catch (_) {
      _byVenueId.remove(key);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> removeFavorite(String venueId) async {
    if (!_auth.hasMemberSession) return;
    final key = _normVenueId(venueId);
    final prev = _byVenueId.remove(key);
    notifyListeners();
    try {
      await _repoWith401Retry(() => _repo.remove(venueId));
    } catch (_) {
      if (prev != null) _byVenueId[key] = prev;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> toggleFavorite({
    required String venueId,
    String? displayName,
    String? primaryImageUrl,
  }) async {
    if (isFavorite(venueId)) {
      await removeFavorite(venueId);
    } else {
      await addFavorite(venueId: venueId, displayName: displayName, primaryImageUrl: primaryImageUrl);
    }
  }
}
