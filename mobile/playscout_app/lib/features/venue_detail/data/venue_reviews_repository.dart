import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../home_discover/data/venues_nearby_repository.dart';
import '../models/review_preview.dart';

class VenueReviewsRepository {
  VenueReviewsRepository({
    http.Client? httpClient,
    String? apiBaseUrl,
  })  : _http = httpClient ?? http.Client(),
        _baseUrl = apiBaseUrl ?? VenuesNearbyRepository.defaultApiBase();

  final http.Client _http;
  final String _baseUrl;

  /// Returns empty list on failure so venue screen still renders.
  Future<List<ReviewPreview>> fetchForVenue({
    required String venueId,
    required String language,
  }) async {
    final uri = Uri.parse('$_baseUrl/reviews').replace(
      queryParameters: <String, String>{
        'venueId': venueId,
        'language': language,
      },
    );
    final res = await _http.get(uri, headers: const {'Accept': 'application/json'});
    if (res.statusCode != 200) {
      return const [];
    }
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    final items = map['items'] as List<dynamic>? ?? const [];
    return items.map((e) => ReviewPreview.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Fetches reviews for full-screen list; throws on HTTP errors (except empty 200 body).
  Future<List<ReviewPreview>> fetchForVenueForList({
    required String venueId,
    required String language,
  }) async {
    final uri = Uri.parse('$_baseUrl/reviews').replace(
      queryParameters: <String, String>{
        'venueId': venueId,
        'language': language,
      },
    );
    final res = await _http.get(uri, headers: const {'Accept': 'application/json'});
    if (res.statusCode == 400) {
      final map = jsonDecode(res.body) as Map<String, dynamic>?;
      final err = '${map?['error'] ?? map?['Error'] ?? ''}';
      if (err == 'unsupported_language') {
        throw VenueReviewsUnsupportedLanguageException();
      }
      throw VenueReviewsLoadException(res.statusCode, res.body);
    }
    if (res.statusCode == 404) {
      throw VenueReviewsVenueNotFoundException();
    }
    if (res.statusCode != 200) {
      throw VenueReviewsLoadException(res.statusCode, res.body);
    }
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    final items = map['items'] as List<dynamic>? ?? const [];
    return items.map((e) => ReviewPreview.fromJson(e as Map<String, dynamic>)).toList();
  }
}

class VenueReviewsLoadException implements Exception {
  VenueReviewsLoadException(this.statusCode, this.body);
  final int statusCode;
  final String body;
}

class VenueReviewsVenueNotFoundException implements Exception {}

class VenueReviewsUnsupportedLanguageException implements Exception {}
