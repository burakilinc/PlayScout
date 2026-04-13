import '../../home_discover/models/discover_filter.dart';
import 'filter_age_band.dart';
import 'filter_environment.dart';

/// Serializable filter state for `GET /venues/nearby` (plus UI-only radius in km).
class VenueNearbyCriteria {
  const VenueNearbyCriteria({
    required this.radiusKm,
    required this.environment,
    this.ageBand,
    required this.amenityFeatureTypeIds,
    required this.requirePlaySupervisor,
    required this.requireChildDropOff,
  });

  final double radiusKm;
  final FilterEnvironment environment;
  final FilterAgeBand? ageBand;
  final Set<int> amenityFeatureTypeIds;
  final bool requirePlaySupervisor;
  final bool requireChildDropOff;

  static const double minRadiusKm = 0.5;
  static const double maxRadiusKm = 10;

  factory VenueNearbyCriteria.initial() => const VenueNearbyCriteria(
        radiusKm: 8,
        environment: FilterEnvironment.none,
        ageBand: null,
        amenityFeatureTypeIds: {},
        requirePlaySupervisor: false,
        requireChildDropOff: false,
      );

  int get radiusMeters => (radiusKm * 1000).round().clamp(500, 10000);

  int? get childAgeMonths => ageBand?.childAgeMonths;

  DiscoverFilter toDiscoverFilter() {
    final ids = <int>{...amenityFeatureTypeIds};
    switch (environment) {
      case FilterEnvironment.indoor:
        ids.add(3);
      case FilterEnvironment.outdoor:
        ids.add(4);
      case FilterEnvironment.none:
        break;
    }
    final sorted = ids.toList()..sort();
    return DiscoverFilter(
      requirePlaySupervisor: requirePlaySupervisor ? true : null,
      requireChildDropOff: requireChildDropOff ? true : null,
      featureTypeIds: sorted,
    );
  }

  VenueNearbyCriteria copyWith({
    double? radiusKm,
    FilterEnvironment? environment,
    Object? ageBand = _sentinel,
    Set<int>? amenityFeatureTypeIds,
    bool? requirePlaySupervisor,
    bool? requireChildDropOff,
  }) {
    return VenueNearbyCriteria(
      radiusKm: radiusKm ?? this.radiusKm,
      environment: environment ?? this.environment,
      ageBand: ageBand == _sentinel ? this.ageBand : ageBand as FilterAgeBand?,
      amenityFeatureTypeIds: amenityFeatureTypeIds ?? this.amenityFeatureTypeIds,
      requirePlaySupervisor: requirePlaySupervisor ?? this.requirePlaySupervisor,
      requireChildDropOff: requireChildDropOff ?? this.requireChildDropOff,
    );
  }

  static const Object _sentinel = Object();
}
