import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../home_discover/data/venues_nearby_repository.dart';

class ReviewsWriteRepository {
  ReviewsWriteRepository({
    required http.Client httpClient,
    String? apiBaseUrl,
  })  : _http = httpClient,
        _baseUrl = apiBaseUrl ?? VenuesNearbyRepository.defaultApiBase();

  final http.Client _http;
  final String _baseUrl;

  Uri get _collection => Uri.parse('$_baseUrl/reviews');

  Future<CreateReviewResult> create({
    required String venueId,
    required int rating,
    required String comment,
    required String originalLanguage,
    int? cleanlinessScore,
    int? safetyScore,
    int? suitabilityForSmallChildrenScore,
  }) async {
    final body = <String, dynamic>{
      'venueId': venueId,
      'rating': rating,
      'comment': comment,
      'originalLanguage': originalLanguage,
      'cleanlinessScore': cleanlinessScore,
      'safetyScore': safetyScore,
      'suitabilityForSmallChildrenScore': suitabilityForSmallChildrenScore,
    }..removeWhere((k, v) => v == null);
    final res = await _http.post(
      _collection,
      headers: const {'Accept': 'application/json', 'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (res.statusCode == 409) {
      throw ReviewAlreadyExistsException();
    }
    if (res.statusCode == 401) {
      throw ReviewsWriteUnauthorizedException();
    }
    if (res.statusCode == 403) {
      throw ReviewsWriteForbiddenException();
    }
    if (res.statusCode == 404) {
      throw ReviewsVenueNotFoundException();
    }
    if (res.statusCode == 400) {
      final map = jsonDecode(res.body) as Map<String, dynamic>?;
      final errs = _parseValidationErrors(map);
      if (errs.isEmpty) {
        final err = '${map?['error'] ?? map?['Error'] ?? ''}';
        if (err == 'unsupported_language') {
          throw ReviewsValidationException({
            'originalLanguage': ['This language is not supported for reviews.'],
          });
        }
      }
      throw ReviewsValidationException(errs);
    }
    if (res.statusCode != 201) {
      throw ReviewsWriteApiException(res.statusCode, res.body);
    }
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    final id = '${map['reviewId'] ?? map['ReviewId'] ?? ''}';
    return CreateReviewResult(reviewId: id);
  }
}

class CreateReviewResult {
  const CreateReviewResult({required this.reviewId});
  final String reviewId;
}

class ReviewAlreadyExistsException implements Exception {}

class ReviewsWriteUnauthorizedException implements Exception {}

class ReviewsWriteForbiddenException implements Exception {}

class ReviewsVenueNotFoundException implements Exception {}

class ReviewsWriteApiException implements Exception {
  ReviewsWriteApiException(this.statusCode, this.body);
  final int statusCode;
  final String body;
}

/// Field key → messages (camelCase / PascalCase keys normalized).
class ReviewsValidationException implements Exception {
  ReviewsValidationException(this.errors);
  final Map<String, List<String>> errors;

  String? firstForField(String fieldLower) {
    for (final e in errors.entries) {
      if (e.key.toLowerCase() == fieldLower.toLowerCase()) {
        final m = e.value;
        if (m.isNotEmpty) return m.first;
      }
    }
    return null;
  }

  String combinedMessage() {
    final parts = <String>[];
    for (final m in errors.values) {
      parts.addAll(m);
    }
    return parts.isEmpty ? 'Please check your review and try again.' : parts.join('\n');
  }
}

Map<String, List<String>> _parseValidationErrors(Map<String, dynamic>? root) {
  if (root == null) return {};
  final raw = root['errors'] ?? root['Errors'];
  if (raw is! Map) return {};
  final out = <String, List<String>>{};
  for (final e in raw.entries) {
    final k = e.key.toString();
    final v = e.value;
    if (v is List) {
      out[k] = v.map((x) => '$x').toList();
    }
  }
  return out;
}
