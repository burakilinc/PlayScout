import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../home_discover/data/venues_nearby_repository.dart';
import '../models/favorite_list_item.dart';

/// HTTP client for favorites. Callers must pass **canonical** venue ids where required.
class FavoritesRepository {
  FavoritesRepository({
    required http.Client httpClient,
    String? apiBaseUrl,
  })  : _http = httpClient,
        _baseUrl = apiBaseUrl ?? VenuesNearbyRepository.defaultApiBase();

  final http.Client _http;
  final String _baseUrl;

  Uri _favoritesCollection([Map<String, String>? query]) {
    final u = Uri.parse('$_baseUrl/favorites');
    if (query == null || query.isEmpty) return u;
    return u.replace(queryParameters: query);
  }

  Future<List<FavoriteListItem>> list({
    double? latitude,
    double? longitude,
  }) async {
    final qp = <String, String>{};
    if (latitude != null) qp['latitude'] = '$latitude';
    if (longitude != null) qp['longitude'] = '$longitude';
    final res = await _http.get(
      _favoritesCollection(qp.isEmpty ? null : qp),
      headers: const {'Accept': 'application/json'},
    );
    if (res.statusCode == 401) {
      throw FavoritesUnauthorizedException();
    }
    if (res.statusCode == 403) {
      throw FavoritesForbiddenException();
    }
    if (res.statusCode != 200) {
      throw FavoritesApiException(res.statusCode, res.body);
    }
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    final raw = map['items'] ?? map['Items'];
    final list = raw is List<dynamic> ? raw : const <dynamic>[];
    return list.map((e) => FavoriteListItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<AddFavoriteResult> add(String canonicalVenueId) async {
    final res = await _http.post(
      _favoritesCollection(),
      headers: const {'Accept': 'application/json', 'Content-Type': 'application/json'},
      body: jsonEncode({'venueId': canonicalVenueId}),
    );
    if (res.statusCode == 401) {
      throw FavoritesUnauthorizedException();
    }
    if (res.statusCode == 403) {
      throw FavoritesForbiddenException();
    }
    if (res.statusCode == 404) {
      throw FavoritesVenueNotFoundException();
    }
    if (res.statusCode != 200) {
      throw FavoritesApiException(res.statusCode, res.body);
    }
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    return AddFavoriteResult(
      favoriteId: '${map['favoriteId'] ?? map['FavoriteId']}',
      venueId: '${map['venueId'] ?? map['VenueId']}',
      wasAlreadyFavorite: map['wasAlreadyFavorite'] as bool? ?? map['WasAlreadyFavorite'] as bool? ?? false,
    );
  }

  /// DELETE /favorites/{venueId}. [canonicalVenueId] must already be normalized.
  /// 204/200: removed. 404: treat as already removed (success, no extra GET).
  Future<void> remove(String canonicalVenueId) async {
    final enc = Uri.encodeComponent(canonicalVenueId);
    final res = await _http.delete(
      Uri.parse('$_baseUrl/favorites/$enc'),
      headers: const {'Accept': 'application/json'},
    );
    if (res.statusCode == 401) {
      throw FavoritesUnauthorizedException();
    }
    if (res.statusCode == 403) {
      throw FavoritesForbiddenException();
    }
    if (res.statusCode == 404) {
      return;
    }
    if (res.statusCode != 204 && res.statusCode != 200) {
      throw FavoritesApiException(res.statusCode, res.body);
    }
  }
}

class AddFavoriteResult {
  const AddFavoriteResult({
    required this.favoriteId,
    required this.venueId,
    required this.wasAlreadyFavorite,
  });

  final String favoriteId;
  final String venueId;
  final bool wasAlreadyFavorite;
}

class FavoritesApiException implements Exception {
  FavoritesApiException(this.statusCode, this.body);
  final int statusCode;
  final String body;
}

class FavoritesUnauthorizedException implements Exception {}

class FavoritesForbiddenException implements Exception {}

class FavoritesVenueNotFoundException implements Exception {}
