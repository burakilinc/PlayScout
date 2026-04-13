import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../home_discover/data/venues_nearby_repository.dart';
import '../../home_discover/models/event_list_item.dart';

class EventsApiRepository {
  EventsApiRepository({
    http.Client? httpClient,
    String? apiBaseUrl,
  })  : _http = httpClient ?? http.Client(),
        _baseUrl = apiBaseUrl ?? VenuesNearbyRepository.defaultApiBase();

  final http.Client _http;
  final String _baseUrl;

  Future<List<EventListItem>> fetchEvents({
    required DateTime fromUtc,
    required DateTime toUtc,
    int page = 1,
    int pageSize = 100,
  }) async {
    final uri = Uri.parse('$_baseUrl/events').replace(
      queryParameters: <String, String>{
        'fromUtc': fromUtc.toUtc().toIso8601String(),
        'toUtc': toUtc.toUtc().toIso8601String(),
        'page': '$page',
        'pageSize': '$pageSize',
      },
    );
    _diag('GET $uri');

    try {
      final res = await _http.get(uri, headers: const {'Accept': 'application/json'});
      _diag('GET $uri -> ${res.statusCode}');
      if (res.statusCode != 200) {
        _diag('GET $uri body: ${_truncate(res.body)}');
        throw EventsApiException(res.statusCode, res.body);
      }
      final map = jsonDecode(res.body) as Map<String, dynamic>;
      final items = map['items'] as List<dynamic>? ?? const [];
      _diag('GET $uri parsed items=${items.length}');
      return items.map((e) => EventListItem.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      _diag('GET $uri threw ${e.runtimeType}: $e');
      rethrow;
    }
  }
}

class EventsApiException implements Exception {
  EventsApiException(this.statusCode, this.body);
  final int statusCode;
  final String body;

  @override
  String toString() => 'EventsApiException($statusCode)';
}

void _diag(String message) {
  if (kDebugMode) {
    // ignore: avoid_print
    print('[API][events] $message');
  }
}

String _truncate(String value, [int max = 400]) =>
    value.length <= max ? value : '${value.substring(0, max)}...';
