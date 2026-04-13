import 'package:flutter/foundation.dart';

import 'models/filter_age_band.dart';
import 'models/filter_environment.dart';
import 'models/venue_nearby_criteria.dart';

/// Mutable UI state for the filter sheet (maps to [VenueNearbyCriteria] on apply).
class FilterOptionsController extends ChangeNotifier {
  FilterOptionsController({VenueNearbyCriteria? initial})
      : _criteria = initial ?? VenueNearbyCriteria.initial();

  VenueNearbyCriteria _criteria;

  VenueNearbyCriteria get criteria => _criteria;

  void setRadiusKm(double km) {
    final v = (km * 2).round() / 2;
    final clamped = v.clamp(VenueNearbyCriteria.minRadiusKm, VenueNearbyCriteria.maxRadiusKm);
    _criteria = VenueNearbyCriteria(
      radiusKm: clamped,
      environment: _criteria.environment,
      ageBand: _criteria.ageBand,
      amenityFeatureTypeIds: {..._criteria.amenityFeatureTypeIds},
      requirePlaySupervisor: _criteria.requirePlaySupervisor,
      requireChildDropOff: _criteria.requireChildDropOff,
    );
    notifyListeners();
  }

  void setEnvironment(FilterEnvironment env) {
    final next = env == _criteria.environment ? FilterEnvironment.none : env;
    _criteria = VenueNearbyCriteria(
      radiusKm: _criteria.radiusKm,
      environment: next,
      ageBand: _criteria.ageBand,
      amenityFeatureTypeIds: {..._criteria.amenityFeatureTypeIds},
      requirePlaySupervisor: _criteria.requirePlaySupervisor,
      requireChildDropOff: _criteria.requireChildDropOff,
    );
    notifyListeners();
  }

  void selectAgeBand(FilterAgeBand band) {
    final next = _criteria.ageBand == band ? null : band;
    _criteria = VenueNearbyCriteria(
      radiusKm: _criteria.radiusKm,
      environment: _criteria.environment,
      ageBand: next,
      amenityFeatureTypeIds: {..._criteria.amenityFeatureTypeIds},
      requirePlaySupervisor: _criteria.requirePlaySupervisor,
      requireChildDropOff: _criteria.requireChildDropOff,
    );
    notifyListeners();
  }

  void toggleAmenity(int featureTypeId) {
    final next = {..._criteria.amenityFeatureTypeIds};
    if (next.contains(featureTypeId)) {
      next.remove(featureTypeId);
    } else {
      next.add(featureTypeId);
    }
    _criteria = VenueNearbyCriteria(
      radiusKm: _criteria.radiusKm,
      environment: _criteria.environment,
      ageBand: _criteria.ageBand,
      amenityFeatureTypeIds: next,
      requirePlaySupervisor: _criteria.requirePlaySupervisor,
      requireChildDropOff: _criteria.requireChildDropOff,
    );
    notifyListeners();
  }

  void togglePlaySupervisor() {
    _criteria = VenueNearbyCriteria(
      radiusKm: _criteria.radiusKm,
      environment: _criteria.environment,
      ageBand: _criteria.ageBand,
      amenityFeatureTypeIds: {..._criteria.amenityFeatureTypeIds},
      requirePlaySupervisor: !_criteria.requirePlaySupervisor,
      requireChildDropOff: _criteria.requireChildDropOff,
    );
    notifyListeners();
  }

  void toggleChildDropOff() {
    _criteria = VenueNearbyCriteria(
      radiusKm: _criteria.radiusKm,
      environment: _criteria.environment,
      ageBand: _criteria.ageBand,
      amenityFeatureTypeIds: {..._criteria.amenityFeatureTypeIds},
      requirePlaySupervisor: _criteria.requirePlaySupervisor,
      requireChildDropOff: !_criteria.requireChildDropOff,
    );
    notifyListeners();
  }

  void reset() {
    _criteria = VenueNearbyCriteria.initial();
    notifyListeners();
  }
}
