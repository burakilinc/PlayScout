import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb, kProfileMode, kReleaseMode;
import 'package:http/http.dart' as http;

import '../../../app/release_api_base.dart';
import '../models/discover_filter.dart';
import '../models/user_location.dart';
import '../models/venue_summary.dart';

class VenuesNearbyRepository {
  VenuesNearbyRepository({
    http.Client? httpClient,
    String? apiBaseUrl,
  })  : _http = httpClient ?? http.Client(),
        _baseUrl = apiBaseUrl ?? defaultApiBase();

  final http.Client _http;
  final String _baseUrl;

  static String defaultApiBase() {
    const fromEnv = String.fromEnvironment('PLAYSCOUT_API_BASE');
    if (fromEnv.isNotEmpty) {
      final resolved = fromEnv.replaceAll(RegExp(r'/$'), '');
      _diag('Resolved base URL from PLAYSCOUT_API_BASE: $resolved');
      return resolved;
    }

    final shipRemote = kReleaseMode || kProfileMode;
    if (shipRemote) {
      const prodDefine = String.fromEnvironment('PLAYSCOUT_PRODUCTION_API_BASE');
      if (prodDefine.isNotEmpty) {
        final resolved = prodDefine.replaceAll(RegExp(r'/$'), '');
        _diag('Resolved base URL from PLAYSCOUT_PRODUCTION_API_BASE: $resolved');
        return resolved;
      }
      final embedded = kPlayScoutMobileReleaseApiBase.trim();
      if (embedded.isNotEmpty) {
        final resolved = embedded.replaceAll(RegExp(r'/$'), '');
        _diag('Resolved base URL from kPlayScoutMobileReleaseApiBase: $resolved');
        return resolved;
      }
      throw StateError(
        'PlayScout: release/profile build needs a public API URL. Either pass '
        '--dart-define=PLAYSCOUT_PRODUCTION_API_BASE=https://your.api.host '
        'when building, or set kPlayScoutMobileReleaseApiBase in '
        'lib/app/release_api_base.dart (no trailing slash).',
      );
    }

    if (kIsWeb) return 'http://localhost:5198';
    if (!kIsWeb && Platform.isAndroid) return 'http://10.0.2.2:5198';
    return 'http://localhost:5198';
  }

  Future<List<VenueSummary>> fetchNearby({
    required UserLocation location,
    required DiscoverFilter filter,
    int radiusMeters = 8000,
    int maxResults = 24,
    int? childAgeMonths,
  }) async {
    final qp = <String, String>{
      'latitude': '${location.latitude}',
      'longitude': '${location.longitude}',
      'radiusMeters': '$radiusMeters',
      'maxResults': '$maxResults',
    };
    if (childAgeMonths != null) {
      qp['childAgeMonths'] = '$childAgeMonths';
    }
    if (filter.requirePlaySupervisor == true) {
      qp['requirePlaySupervisor'] = 'true';
    }
    if (filter.requireChildDropOff == true) {
      qp['requireChildDropOff'] = 'true';
    }

    final buf = StringBuffer('$_baseUrl/venues/nearby?');
    buf.write(qp.entries.map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}').join('&'));
    for (final id in filter.featureTypeIds) {
      buf.write('&featureTypes=$id');
    }
    final uri = Uri.parse(buf.toString());
    _diag('GET $uri');

    try {
      final res = await _http.get(uri, headers: const {'Accept': 'application/json'});
      _diag('GET $uri -> ${res.statusCode}');
      if (res.statusCode != 200) {
        _diag('GET $uri body: ${_truncate(res.body)}');
        throw VenuesNearbyException(res.statusCode, res.body);
      }
      final map = jsonDecode(res.body) as Map<String, dynamic>;
      final items = map['items'] as List<dynamic>? ?? const [];
      _diag('GET $uri parsed items=${items.length}');
      return items
          .map((e) => VenueSummary.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _diag('GET $uri threw ${e.runtimeType}: $e');
      rethrow;
    }
  }
}

class VenuesNearbyException implements Exception {
  VenuesNearbyException(this.statusCode, this.body);
  final int statusCode;
  final String body;

  @override
  String toString() => 'VenuesNearbyException($statusCode)';
}

void _diag(String message) {
  if (kDebugMode) {
    // ignore: avoid_print
    print('[API][venues_nearby] $message');
  }
}

String _truncate(String value, [int max = 400]) =>
    value.length <= max ? value : '${value.substring(0, max)}...';
