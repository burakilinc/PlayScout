import '../home_discover/models/user_location.dart';
import '../home_discover/models/venue_summary.dart';

sealed class InteractiveParkMapState {
  const InteractiveParkMapState();
}

final class InteractiveParkMapLoading extends InteractiveParkMapState {
  const InteractiveParkMapLoading();
}

final class InteractiveParkMapEmpty extends InteractiveParkMapState {
  const InteractiveParkMapEmpty({required this.location});

  final UserLocation location;
}

final class InteractiveParkMapError extends InteractiveParkMapState {
  const InteractiveParkMapError();
}

final class InteractiveParkMapReady extends InteractiveParkMapState {
  const InteractiveParkMapReady({
    required this.location,
    required this.venues,
    required this.selectedVenueId,
  });

  final UserLocation location;
  final List<VenueSummary> venues;

  /// `null` after optional map-background deselect.
  final String? selectedVenueId;

  VenueSummary? get selectedVenue {
    if (selectedVenueId == null) return null;
    for (final v in venues) {
      if (v.id == selectedVenueId) return v;
    }
    return null;
  }
}
