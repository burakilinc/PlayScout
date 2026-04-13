import '../models/user_location.dart';

/// Pluggable location; swap implementation for geolocator later.
abstract class UserLocationSource {
  Future<UserLocation> resolve();
}

/// Seed-aligned coordinates (Little Explorers Hub area) until GPS is wired.
class DevUserLocationSource implements UserLocationSource {
  DevUserLocationSource({
    this.latitude = 41.0082,
    this.longitude = 28.9784,
    this.displayLabel = 'Kadıköy, Istanbul',
  });

  final double latitude;
  final double longitude;
  final String displayLabel;

  @override
  Future<UserLocation> resolve() async => UserLocation(
        latitude: latitude,
        longitude: longitude,
        displayLabel: displayLabel,
      );
}
