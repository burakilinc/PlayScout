import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/event_list_item.dart';
import 'venues_nearby_repository.dart';

class EventsWeekendRepository {
  EventsWeekendRepository({
    http.Client? httpClient,
    String? apiBaseUrl,
  })  : _http = httpClient ?? http.Client(),
        _baseUrl = apiBaseUrl ?? VenuesNearbyRepository.defaultApiBase();

  final http.Client _http;
  final String _baseUrl;

  /// Current or upcoming weekend: Saturday 00:00 → Sunday 23:59:59 (local), sent as UTC.
  Future<List<EventListItem>> fetchThisWeekend({int maxItems = 8}) async {
    final now = DateTime.now();
    final saturdayStart = _weekendSaturdayStart(now);
    final sundayEnd = saturdayStart.add(const Duration(days: 1, hours: 23, minutes: 59, seconds: 59));
    final from = saturdayStart.toUtc();
    final to = sundayEnd.toUtc();

    final uri = Uri.parse('$_baseUrl/events').replace(
      queryParameters: <String, String>{
        'fromUtc': from.toIso8601String(),
        'toUtc': to.toIso8601String(),
        'page': '1',
        'pageSize': '$maxItems',
      },
    );

    final res = await _http.get(uri, headers: const {'Accept': 'application/json'});
    if (res.statusCode != 200) {
      throw EventsWeekendException(res.statusCode, res.body);
    }
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    final items = map['items'] as List<dynamic>? ?? const [];
    return items.map((e) => EventListItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  static DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

  static DateTime _weekendSaturdayStart(DateTime now) {
    final start = _startOfDay(now);
    final w = now.weekday;
    if (w == DateTime.saturday) return start;
    if (w == DateTime.sunday) return start.subtract(const Duration(days: 1));
    final daysUntil = DateTime.saturday - w;
    return start.add(Duration(days: daysUntil));
  }
}

class EventsWeekendException implements Exception {
  EventsWeekendException(this.statusCode, this.body);
  final int statusCode;
  final String body;
}
