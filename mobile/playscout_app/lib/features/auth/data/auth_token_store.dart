import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/pending_auth_intent.dart';
import '../models/token_bundle.dart';

const _kAccess = 'playscout_auth_access_v1';
const _kRefresh = 'playscout_auth_refresh_v1';
const _kAccessExp = 'playscout_auth_access_exp_v1';
const _kRefreshExp = 'playscout_auth_refresh_exp_v1';
const _kUserId = 'playscout_auth_user_id_v1';
const _kGuest = 'playscout_auth_is_guest_v1';

class AuthTokenStore {
  AuthTokenStore(this._prefs);

  final SharedPreferences _prefs;

  Future<void> save(TokenBundle tokens) async {
    await _prefs.setString(_kAccess, tokens.accessToken);
    await _prefs.setString(_kRefresh, tokens.refreshToken);
    await _prefs.setString(_kAccessExp, tokens.accessTokenExpiresAtUtc.toIso8601String());
    await _prefs.setString(_kRefreshExp, tokens.refreshTokenExpiresAtUtc.toIso8601String());
    await _prefs.setString(_kUserId, tokens.userId);
    await _prefs.setBool(_kGuest, tokens.isGuest);
  }

  Future<TokenBundle?> load() async {
    final access = _prefs.getString(_kAccess);
    final refresh = _prefs.getString(_kRefresh);
    final accessExp = _prefs.getString(_kAccessExp);
    final refreshExp = _prefs.getString(_kRefreshExp);
    final userId = _prefs.getString(_kUserId);
    if (access == null ||
        refresh == null ||
        accessExp == null ||
        refreshExp == null ||
        userId == null ||
        userId.isEmpty) {
      return null;
    }
    return TokenBundle(
      accessToken: access,
      refreshToken: refresh,
      accessTokenExpiresAtUtc: DateTime.parse(accessExp).toUtc(),
      refreshTokenExpiresAtUtc: DateTime.parse(refreshExp).toUtc(),
      userId: userId,
      isGuest: _prefs.getBool(_kGuest) ?? false,
    );
  }

  Future<void> clear() async {
    await _prefs.remove(_kAccess);
    await _prefs.remove(_kRefresh);
    await _prefs.remove(_kAccessExp);
    await _prefs.remove(_kRefreshExp);
    await _prefs.remove(_kUserId);
    await _prefs.remove(_kGuest);
  }

  /// Snapshot for Authorization header wiring elsewhere.
  String? get accessTokenOrNull => _prefs.getString(_kAccess);
}

/// Persists [PendingAuthIntent] until consumed after successful auth.
class PendingAuthIntentStore {
  PendingAuthIntentStore(this._prefs);

  final SharedPreferences _prefs;
  static const _k = 'playscout_pending_auth_intent_v1';

  Future<void> setIntent(PendingAuthIntent intent) async {
    await _prefs.setString(_k, jsonEncode(intent.toJson()));
  }

  Future<PendingAuthIntent?> peek() async {
    final raw = _prefs.getString(_k);
    if (raw == null || raw.isEmpty) return null;
    try {
      return PendingAuthIntent.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<PendingAuthIntent?> consume() async {
    final v = await peek();
    await _prefs.remove(_k);
    return v;
  }

  Future<void> clear() async => _prefs.remove(_k);
}
