import 'package:flutter/foundation.dart';

import '../home_discover/data/user_location_source.dart';
import 'data/venue_detail_repository.dart';
import 'data/venue_reviews_repository.dart';
import 'geo/haversine_meters.dart';
import 'venue_detail_state.dart';

class VenueDetailController extends ChangeNotifier {
  VenueDetailController({
    required this.venueId,
    VenueDetailRepository? venueRepository,
    VenueReviewsRepository? reviewsRepository,
    UserLocationSource? locationSource,
  })  : _venueRepository = venueRepository ?? VenueDetailRepository(),
        _reviewsRepository = reviewsRepository ?? VenueReviewsRepository(),
        _locationSource = locationSource ?? DevUserLocationSource();

  final String venueId;
  final VenueDetailRepository _venueRepository;
  final VenueReviewsRepository _reviewsRepository;
  final UserLocationSource _locationSource;

  VenueDetailState _state = const VenueDetailLoading();
  VenueDetailState get state => _state;

  static String reviewsLanguageTag() {
    final loc = PlatformDispatcher.instance.locale;
    final code = loc.languageCode;
    if (code.length == 2) return code;
    return 'en';
  }

  Future<void> load() async {
    _state = const VenueDetailLoading();
    notifyListeners();
    try {
      final venue = await _venueRepository.fetchById(venueId);
      final lang = reviewsLanguageTag();
      final reviews = await _reviewsRepository.fetchForVenue(venueId: venueId, language: lang);
      final loc = await _locationSource.resolve();
      final distance = haversineDistanceMeters(
        lat1: loc.latitude,
        lon1: loc.longitude,
        lat2: venue.latitude,
        lon2: venue.longitude,
      );
      _state = VenueDetailReady(
        venue: venue,
        reviews: reviews,
        distanceMeters: distance,
      );
    } on VenueDetailNotFoundException {
      _state = const VenueDetailError('Venue not found.', isNotFound: true);
    } catch (e) {
      _state = VenueDetailError('$e');
    }
    notifyListeners();
  }

  /// Refetch reviews only when detail is already shown (e.g. after returning from write-review).
  Future<void> reloadReviewsIfReady() async {
    final s = _state;
    if (s is! VenueDetailReady) return;
    try {
      final lang = reviewsLanguageTag();
      final reviews = await _reviewsRepository.fetchForVenue(venueId: venueId, language: lang);
      if (_state is VenueDetailReady && (_state as VenueDetailReady).venue.id == s.venue.id) {
        _state = VenueDetailReady(
          venue: s.venue,
          reviews: reviews,
          distanceMeters: s.distanceMeters,
        );
        notifyListeners();
      }
    } catch (_) {}
  }
}
