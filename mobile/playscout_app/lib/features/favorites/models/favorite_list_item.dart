import '../favorite_venue_ids.dart';

/// Row from `GET /favorites` (`FavoriteListItemDto`).
class FavoriteListItem {
  const FavoriteListItem({
    required this.favoriteId,
    required this.venueId,
    required this.venueName,
    required this.primaryImageUrl,
    required this.distanceMeters,
    required this.averageRating,
    required this.reviewCount,
    required this.minAgeMonths,
    required this.maxAgeMonths,
    required this.hasPlaySupervisor,
    required this.allowsChildDropOff,
    required this.favoritedAtUtc,
  });

  final String favoriteId;
  final String venueId;
  final String venueName;
  final String? primaryImageUrl;
  final double? distanceMeters;
  final double? averageRating;
  final int reviewCount;
  final int? minAgeMonths;
  final int? maxAgeMonths;
  final bool hasPlaySupervisor;
  final bool allowsChildDropOff;
  final DateTime favoritedAtUtc;

  static FavoriteListItem fromJson(Map<String, dynamic> json) {
    DateTime at(String a, String b) => DateTime.parse('${json[a] ?? json[b]}').toUtc();

    double? numOr(String a, String b) {
      final v = json[a] ?? json[b];
      if (v == null) return null;
      return (v as num).toDouble();
    }

    int? intOr(String a, String b) {
      final v = json[a] ?? json[b];
      if (v == null) return null;
      return (v as num).toInt();
    }

    return FavoriteListItem(
      favoriteId: '${json['favoriteId'] ?? json['FavoriteId']}',
      venueId: FavoriteVenueIds.canonical('${json['venueId'] ?? json['VenueId']}'),
      venueName: '${json['venueName'] ?? json['VenueName']}',
      primaryImageUrl: json['primaryImageUrl'] as String? ?? json['PrimaryImageUrl'] as String?,
      distanceMeters: numOr('distanceMeters', 'DistanceMeters'),
      averageRating: numOr('averageRating', 'AverageRating'),
      reviewCount: intOr('reviewCount', 'ReviewCount') ?? 0,
      minAgeMonths: intOr('minAgeMonths', 'MinAgeMonths'),
      maxAgeMonths: intOr('maxAgeMonths', 'MaxAgeMonths'),
      hasPlaySupervisor: json['hasPlaySupervisor'] as bool? ?? json['HasPlaySupervisor'] as bool? ?? false,
      allowsChildDropOff: json['allowsChildDropOff'] as bool? ?? json['AllowsChildDropOff'] as bool? ?? false,
      favoritedAtUtc: at('favoritedAtUtc', 'FavoritedAtUtc'),
    );
  }
}
