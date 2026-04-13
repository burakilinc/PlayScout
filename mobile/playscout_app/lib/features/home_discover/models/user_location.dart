/// Device or dev fallback coordinates + a short label for the header.
class UserLocation {
  const UserLocation({
    required this.latitude,
    required this.longitude,
    required this.displayLabel,
  });

  final double latitude;
  final double longitude;

  /// Shown next to the location pin (not a full geocode string yet).
  final String displayLabel;
}
