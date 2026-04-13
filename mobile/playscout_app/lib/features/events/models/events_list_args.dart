import 'events_chip_state.dart';

/// Route `extra` for expanded / category-filtered event lists.
class EventsListArgs {
  const EventsListArgs({
    required this.chips,
    required this.sectionTitle,
    this.titleKeyword,
    this.weekendRailOnly = false,
  });

  final EventsChipState chips;
  final String sectionTitle;
  final String? titleKeyword;

  /// When true (e.g. “See all” from Weekend Fun), results are limited to the upcoming weekend window.
  final bool weekendRailOnly;
}
