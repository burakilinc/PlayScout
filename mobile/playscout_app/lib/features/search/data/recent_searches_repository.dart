import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

const _kKey = 'playscout_recent_searches_v1';
const _maxItems = 10;

class RecentSearchesRepository {
  Future<List<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => '$e').where((s) => s.trim().isNotEmpty).toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> add(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final prev = await load();
    final next = <String>[q, ...prev.where((s) => s.toLowerCase() != q.toLowerCase())];
    if (next.length > _maxItems) {
      next.removeRange(_maxItems, next.length);
    }
    await prefs.setString(_kKey, jsonEncode(next));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kKey);
  }

  Future<void> remove(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final prev = await load();
    final next = prev.where((s) => s.toLowerCase() != q.toLowerCase()).toList();
    await prefs.setString(_kKey, jsonEncode(next));
  }
}
