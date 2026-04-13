import 'package:flutter/foundation.dart';

import '../../app/app_criteria_controller.dart';
import '../filter_options/models/venue_nearby_criteria.dart';
import '../home_discover/data/user_location_source.dart';
import '../home_discover/data/venues_nearby_repository.dart';
import '../home_discover/models/discover_filter.dart';
import '../home_discover/models/venue_summary.dart';
import 'interactive_park_map_state.dart';

class InteractiveParkMapController extends ChangeNotifier {
  InteractiveParkMapController({
    required VenuesNearbyRepository repository,
    required UserLocationSource locationSource,
    required AppCriteriaController appCriteria,
  })  : _repository = repository,
        _locationSource = locationSource,
        _appCriteria = appCriteria;

  final VenuesNearbyRepository _repository;
  final UserLocationSource _locationSource;
  final AppCriteriaController _appCriteria;

  InteractiveParkMapState _state = const InteractiveParkMapLoading();
  bool _indoorChip = false;
  bool _nearbyChip = false;
  bool _toddlerChip = false;
  String? _selectedVenueId;

  InteractiveParkMapState get state => _state;
  VenueNearbyCriteria get criteriaForFilter => _appCriteria.criteria;
  bool get indoorChip => _indoorChip;
  bool get nearbyChip => _nearbyChip;
  bool get toddlerChip => _toddlerChip;

  DiscoverFilter _effectiveDiscoverFilter() {
    final base = _appCriteria.criteria.toDiscoverFilter();
    final ids = <int>{...base.featureTypeIds};
    if (_indoorChip) {
      ids.add(3);
    }
    final sorted = ids.toList()..sort();
    return DiscoverFilter(
      requirePlaySupervisor: base.requirePlaySupervisor,
      requireChildDropOff: base.requireChildDropOff,
      featureTypeIds: sorted,
    );
  }

  int _effectiveRadiusMeters() {
    final r = _appCriteria.criteria.radiusMeters;
    if (!_nearbyChip) return r;
    return (r * 0.5).round().clamp(500, 10000);
  }

  int? _effectiveChildAgeMonths() {
    if (!_toddlerChip) return _appCriteria.criteria.childAgeMonths;
    final b = _appCriteria.criteria.childAgeMonths;
    if (b == null) return 60;
    return b < 60 ? b : 60;
  }

  Future<void> load() async {
    _state = const InteractiveParkMapLoading();
    notifyListeners();
    try {
      final loc = await _locationSource.resolve();
      final venues = await _repository.fetchNearby(
        location: loc,
        filter: _effectiveDiscoverFilter(),
        radiusMeters: _effectiveRadiusMeters(),
        childAgeMonths: _effectiveChildAgeMonths(),
      );
      if (venues.isEmpty) {
        _selectedVenueId = null;
        _state = InteractiveParkMapEmpty(location: loc);
      } else {
        if (_selectedVenueId == null || !venues.any((v) => v.id == _selectedVenueId)) {
          _selectedVenueId = venues.first.id;
        }
        _state = InteractiveParkMapReady(
          location: loc,
          venues: venues,
          selectedVenueId: _selectedVenueId,
        );
      }
    } catch (_) {
      _state = const InteractiveParkMapError();
    }
    notifyListeners();
  }

  Future<void> refreshLocation() => load();

  void applyFilterCriteria(VenueNearbyCriteria criteria) {
    _appCriteria.setCriteria(criteria);
    load();
  }

  void setIndoorChip(bool value) {
    if (_indoorChip == value) return;
    _indoorChip = value;
    load();
  }

  void setNearbyChip(bool value) {
    if (_nearbyChip == value) return;
    _nearbyChip = value;
    load();
  }

  void setToddlerChip(bool value) {
    if (_toddlerChip == value) return;
    _toddlerChip = value;
    load();
  }

  void selectVenue(String id) {
    final s = _state;
    if (s is! InteractiveParkMapReady) return;
    if (!s.venues.any((v) => v.id == id)) return;
    _selectedVenueId = id;
    _state = InteractiveParkMapReady(
      location: s.location,
      venues: s.venues,
      selectedVenueId: id,
    );
    notifyListeners();
  }

  void deselectVenue() {
    _selectedVenueId = null;
    final s = _state;
    if (s is InteractiveParkMapReady) {
      _state = InteractiveParkMapReady(
        location: s.location,
        venues: s.venues,
        selectedVenueId: null,
      );
      notifyListeners();
    }
  }

  List<VenueSummary> venuesOrEmpty() {
    final s = _state;
    if (s is InteractiveParkMapReady) return s.venues;
    return const [];
  }
}
