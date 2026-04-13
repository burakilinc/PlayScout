import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/token_bundle.dart';

class AuthApiRepository {
  AuthApiRepository({
    http.Client? httpClient,
    String? apiBaseUrl,
  })  : _http = httpClient ?? http.Client(),
        _baseUrl = apiBaseUrl ?? '';

  final http.Client _http;
  final String _baseUrl;

  Uri _u(String path) => Uri.parse('$_baseUrl$path');

  Map<String, String> get _jsonHeaders => const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

  Future<TokenBundle> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final res = await _http.post(
      _u('/auth/register'),
      headers: _jsonHeaders,
      body: jsonEncode({
        'email': email,
        'password': password,
        if (displayName != null && displayName.trim().isNotEmpty) 'displayName': displayName.trim(),
      }),
    );
    return _parseTokenOrThrow(res);
  }

  Future<TokenBundle> login({
    required String email,
    required String password,
  }) async {
    final res = await _http.post(
      _u('/auth/login'),
      headers: _jsonHeaders,
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (res.statusCode == 401) {
      throw AuthApiUnauthorizedException(res.body);
    }
    return _parseTokenOrThrow(res);
  }

  Future<TokenBundle> refresh(String refreshToken) async {
    final res = await _http.post(
      _u('/auth/refresh'),
      headers: _jsonHeaders,
      body: jsonEncode({'refreshToken': refreshToken}),
    );
    if (res.statusCode == 401) {
      throw AuthApiUnauthorizedException(res.body);
    }
    return _parseTokenOrThrow(res);
  }

  Future<TokenBundle> guest() async {
    final res = await _http.post(
      _u('/auth/guest'),
      headers: _jsonHeaders,
    );
    return _parseTokenOrThrow(res);
  }

  Future<TokenBundle> google(String idToken) async {
    final res = await _http.post(
      _u('/auth/google'),
      headers: _jsonHeaders,
      body: jsonEncode({'idToken': idToken}),
    );
    if (res.statusCode == 503) {
      throw AuthApiGoogleNotConfiguredException(res.body);
    }
    if (res.statusCode == 409) {
      throw AuthApiConflictException(res.body);
    }
    if (res.statusCode == 401) {
      throw AuthApiUnauthorizedException(res.body);
    }
    return _parseTokenOrThrow(res);
  }

  Future<TokenBundle> apple({
    required String identityToken,
    String? authorizationCode,
    String? userIdentifier,
  }) async {
    final res = await _http.post(
      _u('/auth/apple'),
      headers: _jsonHeaders,
      body: jsonEncode({
        'identityToken': identityToken,
        'authorizationCode': authorizationCode,
        'userIdentifier': userIdentifier,
      }),
    );
    if (res.statusCode == 501) {
      throw AuthApiAppleNotImplementedException(res.body);
    }
    if (res.statusCode == 401) {
      throw AuthApiUnauthorizedException(res.body);
    }
    return _parseTokenOrThrow(res);
  }

  TokenBundle _parseTokenOrThrow(http.Response res) {
    if (res.statusCode == 200) {
      final map = jsonDecode(res.body) as Map<String, dynamic>;
      return TokenBundle.fromJson(map);
    }
    Map<String, dynamic>? problem;
    try {
      problem = jsonDecode(res.body) as Map<String, dynamic>?;
    } catch (_) {}
    final errors = problem?['errors'] as Map<String, dynamic>?;
    if (errors != null) {
      throw AuthApiValidationException(errors, res.statusCode);
    }
    final title = problem?['title'] as String?;
    final detail = problem?['detail'] as String?;
    throw AuthApiHttpException(res.statusCode, title, detail, res.body);
  }
}

class AuthApiHttpException implements Exception {
  AuthApiHttpException(this.statusCode, this.title, this.detail, this.body);
  final int statusCode;
  final String? title;
  final String? detail;
  final String body;
}

class AuthApiValidationException implements Exception {
  AuthApiValidationException(this.errors, this.statusCode);
  final Map<String, dynamic> errors;
  final int statusCode;

  String? firstMessageFor(String camelField) {
    final v = errors[camelField];
    if (v is List && v.isNotEmpty) return '${v.first}';
    return null;
  }

  String combinedMessage() {
    final buf = StringBuffer();
    for (final e in errors.entries) {
      final msgs = e.value;
      if (msgs is List) {
        for (final m in msgs) {
          if (buf.isNotEmpty) buf.writeln();
          buf.write(m);
        }
      }
    }
    return buf.isEmpty ? 'Please check the form and try again.' : buf.toString();
  }
}

class AuthApiUnauthorizedException implements Exception {
  AuthApiUnauthorizedException(this.body);
  final String body;
}

class AuthApiGoogleNotConfiguredException implements Exception {
  AuthApiGoogleNotConfiguredException(this.body);
  final String body;
}

class AuthApiConflictException implements Exception {
  AuthApiConflictException(this.body);
  final String body;
}

class AuthApiAppleNotImplementedException implements Exception {
  AuthApiAppleNotImplementedException(this.body);
  final String body;
}
