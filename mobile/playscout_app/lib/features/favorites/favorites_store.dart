import 'package:flutter/foundation.dart';

import '../../app/locale_controller.dart';
import '../../l10n/app_localizations.dart';
import '../auth/auth_session.dart';
import 'data/favorites_repository.dart';
import 'favorite_venue_ids.dart';
import 'models/favorite_list_item.dart';

/// Single source of truth for member favorites: id set, list rows, per-venue toggle loading, and sync from GET /favorites.
///
/// Normal UI uses [isFavorite], [isLoading], and [toggleFavorite] — not the repository.
/// After auth resume (guest → member), use [ensureFavorited] so the venue is added, never toggled off.
class FavoritesStore extends ChangeNotifier {
  FavoritesStore({
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

  final Map<String, FavoriteListItem> _itemsByVenueId = {};
  final Set<String> _toggleInFlight = {};
  bool _refreshing = false;
  String? _lastError;
  bool _hadMemberSession = false;

  /// True while a full GET /favorites sync is in progress (e.g. favorites tab / pull-to-refresh).
  bool get isRefreshing => _refreshing;

  String? get lastError => _lastError;

  List<FavoriteListItem> get items {
    final list = _itemsByVenueId.values.toList();
    list.sort((a, b) => b.favoritedAtUtc.compareTo(a.favoritedAtUtc));
    return list;
  }

  bool isFavorite(String venueId) => _itemsByVenueId.containsKey(FavoriteVenueIds.canonical(venueId));

  bool isLoading(String venueId) => _toggleInFlight.contains(FavoriteVenueIds.canonical(venueId));

  void _onAuthSessionChanged() {
    final member = _auth.hasMemberSession;
    if (!member) {
      _hadMemberSession = false;
      if (_itemsByVenueId.isNotEmpty) _itemsByVenueId.clear();
      _toggleInFlight.clear();
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

  /// Initial / explicit sync from GET /favorites (not used during toggle).
  Future<void> refresh({double? latitude, double? longitude}) async {
    if (!_auth.hasMemberSession) return;
    _refreshing = true;
    _lastError = null;
    notifyListeners();
    try {
      final list = await _repoWith401Retry(() => _repo.list(latitude: latitude, longitude: longitude));
      _itemsByVenueId
        ..clear()
        ..addEntries(list.map((e) => MapEntry(FavoriteVenueIds.canonical(e.venueId), e)));
    } catch (e) {
      _lastError = '$e';
    } finally {
      _refreshing = false;
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

  /// Optimistic toggle: add (POST) or remove (DELETE). Guest flows must not call this.
  Future<void> toggleFavorite({
    required String venueId,
    String? displayName,
    String? primaryImageUrl,
  }) async {
    if (!_auth.hasMemberSession) return;
    final key = FavoriteVenueIds.canonical(venueId);
    if (_toggleInFlight.contains(key)) return;

    if (isFavorite(venueId)) {
      await _toggleOff(key);
    } else {
      await _toggleOn(key, displayName: displayName, primaryImageUrl: primaryImageUrl);
    }
  }

  /// Idempotent add: if already favorited, no-op; otherwise POST with the same optimistic path as add (not [toggleFavorite]).
  Future<void> ensureFavorited({required String venueId}) async {
    if (!_auth.hasMemberSession) return;
    final key = FavoriteVenueIds.canonical(venueId);
    if (_itemsByVenueId.containsKey(key)) return;
    if (_toggleInFlight.contains(key)) return;
    await _toggleOn(key, displayName: null, primaryImageUrl: null);
  }

  Future<void> _toggleOn(
    String key, {
    String? displayName,
    String? primaryImageUrl,
  }) async {
    if (_itemsByVenueId.containsKey(key)) return;

    _toggleInFlight.add(key);
    notifyListeners();

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
    _itemsByVenueId[key] = optimistic;
    notifyListeners();

    try {
      final res = await _repoWith401Retry(() => _repo.add(key));
      final serverKey = FavoriteVenueIds.canonical(res.venueId);
      if (serverKey != key) {
        _itemsByVenueId.remove(key);
      }
      _itemsByVenueId[serverKey] = FavoriteListItem(
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
      _itemsByVenueId.remove(key);
      notifyListeners();
      rethrow;
    } finally {
      _toggleInFlight.remove(key);
      notifyListeners();
    }
  }

  Future<void> _toggleOff(String key) async {
    final prev = _itemsByVenueId.remove(key);
    notifyListeners();

    _toggleInFlight.add(key);
    notifyListeners();

    try {
      await _repoWith401Retry(() => _repo.remove(key));
    } catch (_) {
      if (prev != null) {
        _itemsByVenueId[key] = prev;
        notifyListeners();
      }
      rethrow;
    } finally {
      _toggleInFlight.remove(key);
      notifyListeners();
    }
  }
}
