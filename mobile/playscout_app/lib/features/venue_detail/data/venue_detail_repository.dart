import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../home_discover/data/venues_nearby_repository.dart';
import '../models/venue_detail.dart';

class VenueDetailRepository {
  VenueDetailRepository({
    http.Client? httpClient,
    String? apiBaseUrl,
  })  : _http = httpClient ?? http.Client(),
        _baseUrl = apiBaseUrl ?? VenuesNearbyRepository.defaultApiBase();

  final http.Client _http;
  final String _baseUrl;

  Future<VenueDetail> fetchById(String venueId) async {
    final uri = Uri.parse('$_baseUrl/venues/${Uri.encodeComponent(venueId)}');
    _diag('GET $uri');
    try {
      final res = await _http.get(uri, headers: const {'Accept': 'application/json'});
      _diag('GET $uri -> ${res.statusCode}');
      if (res.statusCode == 404) {
        throw VenueDetailNotFoundException();
      }
      if (res.statusCode != 200) {
        _diag('GET $uri body: ${_truncate(res.body)}');
        throw VenueDetailException(res.statusCode, res.body);
      }
      final map = jsonDecode(res.body) as Map<String, dynamic>;
      _diag('GET $uri parsed venue name=${map['name']}');
      return VenueDetail.fromJson(map);
    } catch (e) {
      _diag('GET $uri threw ${e.runtimeType}: $e');
      rethrow;
    }
  }
}

class VenueDetailException implements Exception {
  VenueDetailException(this.statusCode, this.body);
  final int statusCode;
  final String body;
}

class VenueDetailNotFoundException implements Exception {}

void _diag(String message) {
  if (kDebugMode) {
    // ignore: avoid_print
    print('[API][venue_detail] $message');
  }
}

String _truncate(String value, [int max = 400]) =>
    value.length <= max ? value : '${value.substring(0, max)}...';
