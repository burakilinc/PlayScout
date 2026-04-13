import '../models/discover_filter.dart';
import '../models/home_stitch_category.dart';

/// Temporary mapping from Stitch category orbs → GET /venues/nearby query.
/// `events` does not filter venues (weekend rail uses GET /events).
DiscoverFilter discoverFilterForCategory(HomeStitchCategory? category) {
  if (category == null) return DiscoverFilter.all;
  return switch (category) {
    HomeStitchCategory.parks => const DiscoverFilter(featureTypeIds: [4]),
    HomeStitchCategory.indoor => DiscoverFilter.indoor,
    HomeStitchCategory.events => DiscoverFilter.all,
    HomeStitchCategory.cafes => const DiscoverFilter(featureTypeIds: [11]),
    HomeStitchCategory.softPlay => DiscoverFilter.indoor,
  };
}
