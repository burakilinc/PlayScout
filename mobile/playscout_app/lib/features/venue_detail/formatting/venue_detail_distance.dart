import 'package:playscout_app/l10n/app_localizations.dart';

import '../../home_discover/venue_formatters.dart';

/// Distance line for venue detail — matches card/search formatting (meters / km).
String venueDetailDistanceLine(AppLocalizations l10n, double meters) {
  return VenueFormatters.distanceMeters(l10n, meters);
}

String ageChipFromMonths(AppLocalizations l10n, int? minMonths, int? maxMonths) {
  if (minMonths == null && maxMonths == null) return l10n.ageAllAges;
  final y1 = (minMonths ?? 0) ~/ 12;
  final y2 = (maxMonths ?? minMonths ?? 0) ~/ 12;
  return l10n.venueAgeChipRange('$y1', '$y2');
}
