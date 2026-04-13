import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:playscout_app/l10n/app_localizations.dart';

abstract final class VenueFormatters {
  static String distanceMeters(AppLocalizations l10n, double m) {
    if (m < 1000) return l10n.formatDistanceMeters('${m.round()}');
    return l10n.formatDistanceKm((m / 1000).toStringAsFixed(1));
  }

  static String ageRange(AppLocalizations l10n, int? minMonths, int? maxMonths) {
    if (minMonths == null && maxMonths == null) return l10n.ageAllAges;
    final lo = minMonths ?? 0;
    final hi = maxMonths ?? lo;
    final y1 = lo ~/ 12;
    final y2 = hi ~/ 12;
    if (y1 == y2) return l10n.ageYearsSingle('$y1');
    return l10n.ageYearsRange('$y1', '$y2');
  }

  static String ratingLine(AppLocalizations l10n, Locale locale, double? average, int reviewCount) {
    if (average == null) return l10n.ratingNoRatingYet;
    final loc = locale.toLanguageTag();
    final r = NumberFormat('0.0', loc).format(average);
    if (reviewCount <= 0) return r;
    final c = NumberFormat.compact(locale: loc).format(reviewCount);
    return l10n.ratingWithCount(r, c);
  }
}
