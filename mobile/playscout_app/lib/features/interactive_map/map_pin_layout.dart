import '../home_discover/models/user_location.dart';
import '../home_discover/models/venue_summary.dart';

/// Normalizes venue coordinates around [UserLocation] into Stitch-style fractional positions.
abstract final class MapPinLayout {
  static const double _k = 620;

  static double xFraction(VenueSummary venue, UserLocation center) {
    return (0.5 + (venue.longitude - center.longitude) * _k).clamp(0.14, 0.86);
  }

  static double yFraction(VenueSummary venue, UserLocation center) {
    return (0.5 - (venue.latitude - center.latitude) * _k).clamp(0.14, 0.86);
  }
}
