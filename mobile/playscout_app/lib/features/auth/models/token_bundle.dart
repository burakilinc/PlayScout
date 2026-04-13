/// JWT pair + metadata returned by PlayScout `/auth/*` endpoints.
class TokenBundle {
  const TokenBundle({
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExpiresAtUtc,
    required this.refreshTokenExpiresAtUtc,
    required this.userId,
    required this.isGuest,
  });

  final String accessToken;
  final String refreshToken;
  final DateTime accessTokenExpiresAtUtc;
  final DateTime refreshTokenExpiresAtUtc;
  final String userId;
  final bool isGuest;

  static TokenBundle fromJson(Map<String, dynamic> json) {
    String pickStr(String camel, String pascal) {
      final v = json[camel] ?? json[pascal];
      return v == null ? '' : '$v';
    }

    DateTime parseDt(String camel, String pascal) {
      final raw = json[camel] ?? json[pascal];
      if (raw is String) {
        return DateTime.parse(raw).toUtc();
      }
      throw FormatException('Missing or invalid datetime: $camel');
    }

    final ig = json['isGuest'] ?? json['IsGuest'];
    final isGuest = ig is bool ? ig : false;

    return TokenBundle(
      accessToken: pickStr('accessToken', 'AccessToken'),
      refreshToken: pickStr('refreshToken', 'RefreshToken'),
      accessTokenExpiresAtUtc: parseDt('accessTokenExpiresAtUtc', 'AccessTokenExpiresAtUtc'),
      refreshTokenExpiresAtUtc: parseDt('refreshTokenExpiresAtUtc', 'RefreshTokenExpiresAtUtc'),
      userId: pickStr('userId', 'UserId'),
      isGuest: isGuest,
    );
  }
}
