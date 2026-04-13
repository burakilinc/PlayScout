class ReviewPreview {
  const ReviewPreview({
    required this.id,
    required this.authorDisplayName,
    required this.rating,
    required this.displayText,
    required this.isTranslated,
    this.translatedFromLanguage,
    this.originalText,
    required this.originalLanguage,
    required this.requestedLanguage,
    required this.showOriginalLink,
  });

  final String id;
  final String authorDisplayName;
  final int rating;
  final String displayText;
  final bool isTranslated;
  final String? translatedFromLanguage;
  final String? originalText;
  final String originalLanguage;
  final String requestedLanguage;
  final bool showOriginalLink;

  factory ReviewPreview.fromJson(Map<String, dynamic> json) {
    final ota = json['originalTextAvailability'] as Map<String, dynamic>?;
    final showOriginal = (ota?['isIncludedInResponse'] as bool?) ?? false;
    return ReviewPreview(
      id: '${json['id']}',
      authorDisplayName: json['authorDisplayName'] as String,
      rating: (json['rating'] as num).toInt(),
      displayText: json['displayText'] as String,
      isTranslated: json['isTranslated'] as bool? ?? false,
      translatedFromLanguage: json['translatedFromLanguage'] as String?,
      originalText: json['originalText'] as String?,
      originalLanguage: json['originalLanguage'] as String? ?? 'en',
      requestedLanguage: json['requestedLanguage'] as String? ?? 'en',
      showOriginalLink: showOriginal,
    );
  }
}
