/// Maps UI chips to GET /venues/nearby query flags.
class DiscoverFilter {
  const DiscoverFilter({
    this.requirePlaySupervisor,
    this.requireChildDropOff,
    this.featureTypeIds = const [],
  });

  final bool? requirePlaySupervisor;
  final bool? requireChildDropOff;
  final List<int> featureTypeIds;

  static const DiscoverFilter all = DiscoverFilter();

  static const DiscoverFilter indoor = DiscoverFilter(featureTypeIds: <int>[3]);

  static const DiscoverFilter outdoor = DiscoverFilter(featureTypeIds: <int>[4]);

  static const DiscoverFilter supervised =
      DiscoverFilter(requirePlaySupervisor: true);

  static const DiscoverFilter dropOff = DiscoverFilter(requireChildDropOff: true);

  @override
  bool operator ==(Object other) =>
      other is DiscoverFilter &&
      requirePlaySupervisor == other.requirePlaySupervisor &&
      requireChildDropOff == other.requireChildDropOff &&
      _listEq(featureTypeIds, other.featureTypeIds);

  @override
  int get hashCode => Object.hash(
        requirePlaySupervisor,
        requireChildDropOff,
        Object.hashAll(featureTypeIds),
      );

  static bool _listEq(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
