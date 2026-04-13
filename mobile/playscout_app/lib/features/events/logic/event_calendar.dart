import '../models/events_chip_state.dart';

/// Local weekend window (Saturday 00:00 → Sunday end), aligned with [EventsWeekendRepository].
DateTime weekendSaturdayStart(DateTime now) {
  final start = DateTime(now.year, now.month, now.day);
  final w = now.weekday;
  if (w == DateTime.saturday) return start;
  if (w == DateTime.sunday) return start.subtract(const Duration(days: 1));
  final daysUntil = DateTime.saturday - w;
  return start.add(Duration(days: daysUntil));
}

DateTime weekendSundayEnd(DateTime saturdayStart) {
  return saturdayStart.add(const Duration(days: 1, hours: 23, minutes: 59, seconds: 59));
}

bool startsInWeekendWindow(DateTime startsAt, DateTime saturdayStart) {
  final end = weekendSundayEnd(saturdayStart);
  final local = startsAt.toLocal();
  return !local.isBefore(saturdayStart) && !local.isAfter(end);
}

(DateTime, DateTime) eventQueryUtcRange(EventsChipState chips) {
  final now = DateTime.now();
  if (chips.thisWeekend) {
    final sat = weekendSaturdayStart(now);
    final end = weekendSundayEnd(sat);
    return (sat.toUtc(), end.toUtc());
  }
  return (
    now.toUtc().subtract(const Duration(hours: 6)),
    now.toUtc().add(const Duration(days: 90)),
  );
}
