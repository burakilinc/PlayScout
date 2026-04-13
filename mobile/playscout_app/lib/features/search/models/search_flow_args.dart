/// Route `extra` for Search Results / Empty. Chips mirror UI on both screens.
class SearchFlowArgs {
  const SearchFlowArgs({
    required this.query,
    this.nearbyChip = false,
    this.freeChip = false,
    this.indoorChip = false,
    this.age05Chip = false,
  });

  final String query;
  final bool nearbyChip;
  /// UI only — not sent to the API.
  final bool freeChip;
  final bool indoorChip;
  final bool age05Chip;

  static const Object _sentinel = Object();

  SearchFlowArgs copyWith({
    String? query,
    Object? nearbyChip = _sentinel,
    Object? freeChip = _sentinel,
    Object? indoorChip = _sentinel,
    Object? age05Chip = _sentinel,
  }) {
    return SearchFlowArgs(
      query: query ?? this.query,
      nearbyChip: nearbyChip == _sentinel ? this.nearbyChip : nearbyChip as bool,
      freeChip: freeChip == _sentinel ? this.freeChip : freeChip as bool,
      indoorChip: indoorChip == _sentinel ? this.indoorChip : indoorChip as bool,
      age05Chip: age05Chip == _sentinel ? this.age05Chip : age05Chip as bool,
    );
  }
}
