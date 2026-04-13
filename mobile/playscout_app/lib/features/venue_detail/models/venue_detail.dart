class VenueDetail {
  const VenueDetail({
    required this.id,
    required this.name,
    this.description,
    required this.latitude,
    required this.longitude,
    required this.hasPlaySupervisor,
    required this.allowsChildDropOff,
    this.minAgeMonths,
    this.maxAgeMonths,
    this.averageRating,
    required this.reviewCount,
    required this.featureTypes,
    required this.images,
  });

  final String id;
  final String name;
  final String? description;
  final double latitude;
  final double longitude;
  final bool hasPlaySupervisor;
  final bool allowsChildDropOff;
  final int? minAgeMonths;
  final int? maxAgeMonths;
  final double? averageRating;
  final int reviewCount;
  final List<int> featureTypes;
  final List<VenueDetailImage> images;

  factory VenueDetail.fromJson(Map<String, dynamic> json) {
    final rawFeatures = json['features'] as List<dynamic>? ?? const [];
    final features = <int>[];
    for (final e in rawFeatures) {
      if (e is int) {
        features.add(e);
      } else if (e is Map<String, dynamic>) {
        final t = e['type'];
        if (t is int) {
          features.add(t);
        } else if (t is num) {
          features.add(t.toInt());
        }
      }
    }
    final imgs = (json['images'] as List<dynamic>? ?? const [])
        .map((e) => VenueDetailImage.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return VenueDetail(
      id: '${json['id']}',
      name: json['name'] as String,
      description: json['description'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      hasPlaySupervisor: json['hasPlaySupervisor'] as bool,
      allowsChildDropOff: json['allowsChildDropOff'] as bool,
      minAgeMonths: (json['minAgeMonths'] as num?)?.toInt(),
      maxAgeMonths: (json['maxAgeMonths'] as num?)?.toInt(),
      averageRating: (json['averageRating'] as num?)?.toDouble(),
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      featureTypes: features,
      images: imgs,
    );
  }
}

class VenueDetailImage {
  const VenueDetailImage({
    required this.id,
    required this.url,
    required this.sortOrder,
    this.altText,
  });

  final String id;
  final String url;
  final int sortOrder;
  final String? altText;

  factory VenueDetailImage.fromJson(Map<String, dynamic> json) {
    return VenueDetailImage(
      id: '${json['id']}',
      url: json['url'] as String,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      altText: json['altText'] as String?,
    );
  }
}
