import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../home_discover/data/venues_nearby_repository.dart';
import '../models/create_suggestion_result.dart';

class SuggestionsRepository {
  SuggestionsRepository({
    required http.Client httpClient,
    String? apiBaseUrl,
  })  : _http = httpClient,
        _baseUrl = apiBaseUrl ?? VenuesNearbyRepository.defaultApiBase();

  final http.Client _http;
  final String _baseUrl;

  Uri get _collection => Uri.parse('$_baseUrl/suggestions');

  Future<CreateSuggestionResult> create(CreateSuggestionPayload payload) async {
    final res = await _http.post(
      _collection,
      headers: const {'Accept': 'application/json', 'Content-Type': 'application/json'},
      body: jsonEncode(payload.toJson()),
    );
    if (res.statusCode == 401) {
      throw SuggestionsUnauthorizedException();
    }
    if (res.statusCode == 403) {
      throw SuggestionsForbiddenException();
    }
    if (res.statusCode == 400) {
      final map = jsonDecode(res.body) as Map<String, dynamic>?;
      throw SuggestionsValidationException(_parseValidationErrors(map));
    }
    if (res.statusCode != 201) {
      throw SuggestionsApiException(res.statusCode, res.body);
    }
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    return CreateSuggestionResult.fromJson(map);
  }
}

class CreateSuggestionPayload {
  const CreateSuggestionPayload({
    required this.name,
    required this.category,
    this.latitude,
    this.longitude,
    this.locationLabel,
    this.description,
    this.minAgeMonths,
    this.maxAgeMonths,
    required this.hasPlaySupervisor,
    required this.allowsChildDropOff,
    this.optionalAmenities,
  });

  final String name;
  final int category;
  final double? latitude;
  final double? longitude;
  final String? locationLabel;
  final String? description;
  final int? minAgeMonths;
  final int? maxAgeMonths;
  final bool hasPlaySupervisor;
  final bool allowsChildDropOff;
  final List<int>? optionalAmenities;

  Map<String, dynamic> toJson() {
    final amenities = optionalAmenities;
    return {
      'name': name,
      'category': category,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (locationLabel != null) 'locationLabel': locationLabel,
      if (description != null) 'description': description,
      if (minAgeMonths != null) 'minAgeMonths': minAgeMonths,
      if (maxAgeMonths != null) 'maxAgeMonths': maxAgeMonths,
      'hasPlaySupervisor': hasPlaySupervisor,
      'allowsChildDropOff': allowsChildDropOff,
      if (amenities != null && amenities.isNotEmpty) 'optionalAmenities': amenities,
    };
  }
}

class SuggestionsUnauthorizedException implements Exception {}

class SuggestionsForbiddenException implements Exception {}

class SuggestionsApiException implements Exception {
  SuggestionsApiException(this.statusCode, this.body);
  final int statusCode;
  final String body;
}

class SuggestionsValidationException implements Exception {
  SuggestionsValidationException(this.errors);
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
    return parts.join('\n');
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
