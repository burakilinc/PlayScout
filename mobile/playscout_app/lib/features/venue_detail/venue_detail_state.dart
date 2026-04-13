import 'models/review_preview.dart';
import 'models/venue_detail.dart';

sealed class VenueDetailState {
  const VenueDetailState();
}

final class VenueDetailLoading extends VenueDetailState {
  const VenueDetailLoading();
}

final class VenueDetailReady extends VenueDetailState {
  const VenueDetailReady({
    required this.venue,
    required this.reviews,
    required this.distanceMeters,
  });

  final VenueDetail venue;
  final List<ReviewPreview> reviews;
  final double distanceMeters;
}

final class VenueDetailError extends VenueDetailState {
  const VenueDetailError(this.message, {this.isNotFound = false});
  final String message;
  final bool isNotFound;
}
