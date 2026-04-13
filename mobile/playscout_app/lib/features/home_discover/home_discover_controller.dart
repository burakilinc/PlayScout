import 'package:flutter/foundation.dart';

import '../../app/app_criteria_controller.dart';
import '../filter_options/models/venue_nearby_criteria.dart';
import 'data/discover_filter_from_category.dart';
import 'data/events_weekend_repository.dart';
import 'data/user_location_source.dart';
import 'data/venues_nearby_repository.dart';
import 'home_discover_state.dart';
import 'models/event_list_item.dart';
import 'models/home_stitch_category.dart';

class HomeDiscoverController extends ChangeNotifier {
  HomeDiscoverController({
    required VenuesNearbyRepository repository,
    required UserLocationSource locationSource,
    required AppCriteriaController appCriteria,
    EventsWeekendRepository? eventsRepository,
  })  : _repository = repository,
        _locationSource = locationSource,
        _appCriteria = appCriteria,
        _eventsRepository = eventsRepository ?? EventsWeekendRepository();

  final VenuesNearbyRepository _repository;
  final UserLocationSource _locationSource;
  final AppCriteriaController _appCriteria;
  final EventsWeekendRepository _eventsRepository;

  HomeDiscoverState _state = const HomeDiscoverLoading();
  /// `null` after “show all” — no orb ring; requests use [DiscoverFilter.all].
  HomeStitchCategory? _category = HomeStitchCategory.parks;

  /// When true, nearby requests use [_appCriteria] instead of the selected orb category.
  bool _useVenueCriteriaForApi = false;

  HomeDiscoverState get state => _state;
  HomeStitchCategory? get selectedCategory => _category;

  /// Shared criteria — same object as Map / Search filter sheet.
  VenueNearbyCriteria get criteriaForFilterUi => _appCriteria.criteria;

  void applyNearbyCriteria(VenueNearbyCriteria criteria) {
    _appCriteria.setCriteria(criteria);
    _useVenueCriteriaForApi = true;
    _category = null;
    load();
  }

  Future<void> load() async {
    _state = const HomeDiscoverLoading();
    notifyListeners();
    try {
      final loc = await _locationSource.resolve();
      final filter = _useVenueCriteriaForApi
          ? _appCriteria.criteria.toDiscoverFilter()
          : discoverFilterForCategory(_category);
      final radiusMeters = _useVenueCriteriaForApi ? _appCriteria.criteria.radiusMeters : 8000;
      final childAgeMonths = _useVenueCriteriaForApi ? _appCriteria.criteria.childAgeMonths : null;
      List<EventListItem> weekend = const [];
      try {
        weekend = await _eventsRepository.fetchThisWeekend();
      } catch (_) {
        weekend = const [];
      }
      final venues = await _repository.fetchNearby(
        location: loc,
        filter: filter,
        radiusMeters: radiusMeters,
        childAgeMonths: childAgeMonths,
      );
      _state = HomeDiscoverReady(
        location: loc,
        venues: venues,
        weekendEvents: weekend,
        selectedCategory: _category,
      );
    } catch (e) {
      _state = HomeDiscoverError('$e');
    }
    notifyListeners();
  }

  Future<void> refresh() => load();

  void selectCategory(HomeStitchCategory category) {
    final hadCriteria = _useVenueCriteriaForApi;
    _useVenueCriteriaForApi = false;
    if (_category == category && !hadCriteria) return;
    _category = category;
    load();
  }

  /// Clears category filter (all venue types) and clears orb selection.
  void resetCategoryFilter() {
    _useVenueCriteriaForApi = false;
    _category = null;
    _appCriteria.resetToInitial();
    load();
  }
}
