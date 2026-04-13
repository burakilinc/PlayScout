import 'models/event_list_item.dart';
import 'models/home_stitch_category.dart';
import 'models/user_location.dart';
import 'models/venue_summary.dart';

sealed class HomeDiscoverState {
  const HomeDiscoverState();
}

final class HomeDiscoverLoading extends HomeDiscoverState {
  const HomeDiscoverLoading();
}

final class HomeDiscoverReady extends HomeDiscoverState {
  const HomeDiscoverReady({
    required this.location,
    required this.venues,
    required this.weekendEvents,
    required this.selectedCategory,
  });

  final UserLocation location;
  final List<VenueSummary> venues;
  final List<EventListItem> weekendEvents;
  final HomeStitchCategory? selectedCategory;
}

final class HomeDiscoverError extends HomeDiscoverState {
  const HomeDiscoverError(this.message);
  final String message;
}
