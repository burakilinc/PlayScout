import 'package:http/http.dart' as http;

import '../auth_session.dart';

/// Injects `Authorization: Bearer …` from [AuthSession.bearerForApi] on each request.
class AuthAwareHttpClient extends http.BaseClient {
  AuthAwareHttpClient(this._auth, this._inner);

  final AuthSession _auth;
  final http.Client _inner;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final bearer = await _auth.bearerForApi();
    if (bearer != null && bearer.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $bearer';
    }
    return _inner.send(request);
  }

  @override
  void close() => _inner.close();
}
