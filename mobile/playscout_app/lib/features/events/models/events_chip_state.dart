class EventsChipState {
  const EventsChipState({
    this.nearby = false,
    this.thisWeekend = true,
    this.free = false,
    this.indoor = false,
    this.age05 = false,
    this.age610 = false,
  });

  final bool nearby;
  final bool thisWeekend;
  final bool free;
  final bool indoor;
  final bool age05;
  final bool age610;

  static const Object _unset = Object();

  EventsChipState copyWith({
    Object? nearby = _unset,
    Object? thisWeekend = _unset,
    Object? free = _unset,
    Object? indoor = _unset,
    Object? age05 = _unset,
    Object? age610 = _unset,
  }) {
    return EventsChipState(
      nearby: nearby == _unset ? this.nearby : nearby as bool,
      thisWeekend: thisWeekend == _unset ? this.thisWeekend : thisWeekend as bool,
      free: free == _unset ? this.free : free as bool,
      indoor: indoor == _unset ? this.indoor : indoor as bool,
      age05: age05 == _unset ? this.age05 : age05 as bool,
      age610: age610 == _unset ? this.age610 : age610 as bool,
    );
  }
}
