class EventListItem {
  const EventListItem({
    required this.id,
    required this.title,
    required this.startsAt,
    required this.endsAt,
    this.venueId,
    this.venueName,
    this.minAgeMonths,
    this.maxAgeMonths,
    this.locationSummary,
  });

  final String id;
  final String title;
  final DateTime startsAt;
  final DateTime endsAt;
  final String? venueId;
  final String? venueName;
  final int? minAgeMonths;
  final int? maxAgeMonths;
  final String? locationSummary;

  factory EventListItem.fromJson(Map<String, dynamic> json) {
    return EventListItem(
      id: '${json['id']}',
      title: json['title'] as String,
      startsAt: DateTime.parse(json['startsAt'] as String),
      endsAt: DateTime.parse(json['endsAt'] as String),
      venueId: json['venueId'] as String?,
      venueName: json['venueName'] as String?,
      minAgeMonths: (json['minAgeMonths'] as num?)?.toInt(),
      maxAgeMonths: (json['maxAgeMonths'] as num?)?.toInt(),
      locationSummary: json['locationSummary'] as String?,
    );
  }
}
