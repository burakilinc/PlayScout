class VenueSummary {
  const VenueSummary({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.distanceMeters,
    required this.hasPlaySupervisor,
    required this.allowsChildDropOff,
    required this.minAgeMonths,
    required this.maxAgeMonths,
    required this.averageRating,
    required this.reviewCount,
    required this.featureTypes,
    required this.primaryImageUrl,
  });

  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final double distanceMeters;
  final bool hasPlaySupervisor;
  final bool allowsChildDropOff;
  final int? minAgeMonths;
  final int? maxAgeMonths;
  final double? averageRating;
  final int reviewCount;
  final List<int> featureTypes;
  final String? primaryImageUrl;

  factory VenueSummary.fromJson(Map<String, dynamic> json) {
    return VenueSummary(
      id: '${json['id']}',
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      distanceMeters: (json['distanceMeters'] as num).toDouble(),
      hasPlaySupervisor: json['hasPlaySupervisor'] as bool,
      allowsChildDropOff: json['allowsChildDropOff'] as bool,
      minAgeMonths: (json['minAgeMonths'] as num?)?.toInt(),
      maxAgeMonths: (json['maxAgeMonths'] as num?)?.toInt(),
      averageRating: (json['averageRating'] as num?)?.toDouble(),
      reviewCount: (json['reviewCount'] as num).toInt(),
      featureTypes: (json['featureTypes'] as List<dynamic>? ?? const [])
          .map((e) => (e as num).toInt())
          .toList(),
      primaryImageUrl: json['primaryImageUrl'] as String?,
    );
  }
}
