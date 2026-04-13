import 'package:flutter/foundation.dart';

import '../home_discover/models/event_list_item.dart';
import 'data/events_api_repository.dart';
import 'logic/event_calendar.dart' show eventQueryUtcRange, startsInWeekendWindow, weekendSaturdayStart;
import 'logic/event_filters.dart';
import 'models/events_chip_state.dart';

class EventsActivitiesController extends ChangeNotifier {
  EventsActivitiesController({EventsApiRepository? repository})
      : _repository = repository ?? EventsApiRepository();

  final EventsApiRepository _repository;

  EventsChipState _chips = const EventsChipState();
  List<EventListItem> _raw = const [];
  bool _loading = true;
  String? _error;

  EventsChipState get chips => _chips;
  bool get loading => _loading;
  String? get error => _error;
  List<EventListItem> get raw => _raw;

  List<EventListItem> get filtered => applyEventChips(_raw, _chips);

  EventListItem? get hero {
    final f = filtered;
    if (f.isEmpty) return null;
    return f.first;
  }

  List<EventListItem> get weekendRail {
    final f = filtered;
    final h = hero;
    final sat = weekendSaturdayStart(DateTime.now());
    return f
        .where((e) => startsInWeekendWindow(e.startsAt, sat))
        .where((e) => h == null || e.id != h.id)
        .toList();
  }

  /// Rows with a venue name; excludes hero; capped for layout.
  List<EventListItem> get nearbyRows {
    final h = hero;
    final f = filtered;
    final rows = f.where((e) => (e.venueName ?? '').isNotEmpty).where((e) => h == null || e.id != h.id).toList();
    rows.sort((a, b) => a.startsAt.compareTo(b.startsAt));
    return rows.take(8).toList();
  }

  void toggleChip(String id) {
    switch (id) {
      case 'nearby':
        _chips = _chips.copyWith(nearby: !_chips.nearby);
      case 'weekend':
        _chips = _chips.copyWith(thisWeekend: !_chips.thisWeekend);
      case 'free':
        _chips = _chips.copyWith(free: !_chips.free);
      case 'indoor':
        _chips = _chips.copyWith(indoor: !_chips.indoor);
      case 'age05':
        _chips = _chips.copyWith(age05: !_chips.age05);
      case 'age610':
        _chips = _chips.copyWith(age610: !_chips.age610);
      default:
        return;
    }
    notifyListeners();
    load();
  }

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final range = eventQueryUtcRange(_chips);
      _raw = await _repository.fetchEvents(
        fromUtc: range.$1,
        toUtc: range.$2,
        pageSize: 100,
      );
      _error = null;
    } catch (e) {
      _error = '$e';
      _raw = const [];
    }
    _loading = false;
    notifyListeners();
  }
}
