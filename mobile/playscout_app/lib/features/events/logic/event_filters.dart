import '../../home_discover/models/event_list_item.dart';
import '../models/events_chip_state.dart';
bool _overlapsAgeMonths(EventListItem e, int bandMin, int bandMax) {
  final min = e.minAgeMonths ?? 0;
  final max = e.maxAgeMonths ?? 10000;
  return min <= bandMax && max >= bandMin;
}

/// Client-side filters (GET /events has no free/indoor/geo).
List<EventListItem> applyEventChips(List<EventListItem> items, EventsChipState chips) {
  var list = List<EventListItem>.from(items);

  if (chips.nearby) {
    list = list.where((e) => e.venueId != null).toList();
  }

  if (chips.age05 || chips.age610) {
    list = list.where((e) {
      final o5 = _overlapsAgeMonths(e, 0, 60);
      final o610 = _overlapsAgeMonths(e, 72, 120);
      if (chips.age05 && chips.age610) return o5 || o610;
      if (chips.age05) return o5;
      if (chips.age610) return o610;
      return true;
    }).toList();
  }

  return list;
}

List<EventListItem> applyTitleKeyword(List<EventListItem> items, String? keyword) {
  if (keyword == null || keyword.trim().isEmpty) return items;
  final k = keyword.trim().toLowerCase();
  return items.where((e) => e.title.toLowerCase().contains(k)).toList();
}
