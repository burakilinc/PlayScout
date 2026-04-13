import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController extends ChangeNotifier {
  LocaleController(this._prefs);

  static const String _key = 'playscout.locale.languageCode';
  static const List<String> supportedLanguageCodes = [
    'tr',
    'en',
    'ja',
    'zh',
    'de',
    'fr',
    'ko',
    'pt',
    'es',
    'ru',
    'ar',
    'hi',
    'it',
  ];

  final SharedPreferences _prefs;
  Locale? _locale;

  Locale? get locale => _locale;

  /// Effective locale for lookups when the user follows the device (no override).
  Locale get resolvedLocale => locale ?? _resolveDeviceLocale();

  Future<void> restore() async {
    final code = _prefs.getString(_key);
    if (code == null || code.isEmpty || !supportedLanguageCodes.contains(code)) {
      _locale = _resolveDeviceLocale();
      return;
    }
    _locale = Locale(code);
  }

  Future<void> setLanguageCode(String languageCode) async {
    _locale = Locale(languageCode);
    await _prefs.setString(_key, languageCode);
    notifyListeners();
  }

  Future<void> useDeviceDefault() async {
    _locale = null;
    await _prefs.remove(_key);
    notifyListeners();
  }

  Locale _resolveDeviceLocale() {
    final lang = PlatformDispatcher.instance.locale.languageCode.toLowerCase();
    if (supportedLanguageCodes.contains(lang)) {
      return Locale(lang);
    }
    return const Locale('en');
  }
}
