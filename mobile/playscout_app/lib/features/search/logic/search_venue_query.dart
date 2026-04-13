import 'package:playscout_app/l10n/app_localizations.dart';

import '../../filter_options/models/venue_nearby_criteria.dart';
import '../../home_discover/models/discover_filter.dart';
import '../../home_discover/models/venue_summary.dart';

/// Composes GET /venues/nearby query from shared [VenueNearbyCriteria] plus search chips.
DiscoverFilter effectiveDiscoverFilter(
  VenueNearbyCriteria base, {
  required bool indoorChip,
}) {
  final baseFilter = base.toDiscoverFilter();
  final ids = <int>{...baseFilter.featureTypeIds};
  if (indoorChip) {
    ids.add(3);
  }
  final sorted = ids.toList()..sort();
  return DiscoverFilter(
    requirePlaySupervisor: baseFilter.requirePlaySupervisor,
    requireChildDropOff: baseFilter.requireChildDropOff,
    featureTypeIds: sorted,
  );
}

int effectiveRadiusMeters(VenueNearbyCriteria base, {required bool nearbyChip}) {
  final r = base.radiusMeters;
  if (!nearbyChip) return r;
  return (r * 0.5).round().clamp(500, 10000);
}

int? effectiveChildAgeMonths(VenueNearbyCriteria base, {required bool age05Chip}) {
  if (!age05Chip) return base.childAgeMonths;
  final b = base.childAgeMonths;
  if (b == null) return 60;
  return b < 60 ? b : 60;
}

bool venueNameMatchesQuery(VenueSummary v, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return true;
  return v.name.toLowerCase().contains(q);
}

List<VenueSummary> filterVenuesByName(List<VenueSummary> venues, String query) {
  return venues.where((v) => venueNameMatchesQuery(v, query)).toList();
}

String formatSearchDistanceMeters(AppLocalizations l10n, double meters) {
  if (meters < 1000) {
    return l10n.formatDistanceMeters('${meters.round()}');
  }
  final km = meters / 1000;
  return l10n.formatDistanceKm(km.toStringAsFixed(km >= 10 ? 0 : 1));
}

String _ageLabel(AppLocalizations l10n, int months) {
  if (months < 24) return l10n.ageMonthsShort('$months');
  final y = months ~/ 12;
  return l10n.ageYearsSingle('$y');
}

String formatSearchAgeRange(AppLocalizations l10n, VenueSummary v) {
  final min = v.minAgeMonths;
  final max = v.maxAgeMonths;
  if (min == null && max == null) return l10n.ageAllAges;
  if (min != null && max != null) {
    return '${_ageLabel(l10n, min)}–${_ageLabel(l10n, max)}';
  }
  if (min != null) return l10n.ageYearsPlusShort(_ageLabel(l10n, min));
  return l10n.ageUpToWithLabel(_ageLabel(l10n, max!));
}
