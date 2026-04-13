import 'package:intl/intl.dart';
import 'package:playscout_app/l10n/app_localizations.dart';

import '../../home_discover/models/event_list_item.dart';

String formatEventHeroWhen(AppLocalizations l10n, String localeTag, EventListItem e) {
  final age = formatEventAgeShort(l10n, e);
  final when = DateFormat('EEE, h:mm a', localeTag).format(e.startsAt.toLocal());
  return age.isEmpty ? when : '$when • $age';
}

String formatEventRailWhen(String localeTag, EventListItem e) {
  return DateFormat('EEE, h:mm a', localeTag).format(e.startsAt.toLocal());
}

String formatEventNearbyWhen(AppLocalizations l10n, String localeTag, EventListItem e) {
  final local = e.startsAt.toLocal();
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final d = DateTime(local.year, local.month, local.day);
  if (d == today) {
    final time = DateFormat('h:mm a', localeTag).format(local);
    return l10n.eventTodayTime(time);
  }
  return DateFormat('EEE, MMM d • h:mm a', localeTag).format(local);
}

String formatEventAgeShort(AppLocalizations l10n, EventListItem e) {
  final min = e.minAgeMonths;
  final max = e.maxAgeMonths;
  if (min == null && max == null) return '';
  if (min != null && max != null) {
    final a = (min / 12).floor();
    final b = (max / 12).floor();
    return l10n.eventAgesRangeLabel('$a', '$b');
  }
  if (min != null) {
    return l10n.eventAgesMinPlusLabel('${(min / 12).floor()}');
  }
  return l10n.eventAgesUpToOnly('${(max! / 12).floor()}');
}

String formatEventAgeLine(AppLocalizations l10n, EventListItem e) {
  final min = e.minAgeMonths;
  final max = e.maxAgeMonths;
  if (min == null && max == null) return l10n.ageAllAges;
  if (min != null && max != null) {
    return l10n.ageYearsRange('${(min / 12).floor()}', '${(max / 12).floor()}');
  }
  if (min != null) return l10n.ageYearsPlusShort('${(min / 12).floor()}');
  return l10n.ageUpToWithLabel(l10n.ageYearsSingle('${(max! / 12).floor()}'));
}
