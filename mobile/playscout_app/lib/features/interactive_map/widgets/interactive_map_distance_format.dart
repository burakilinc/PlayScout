import 'package:playscout_app/l10n/app_localizations.dart';

abstract final class InteractiveMapDistanceFormat {
  static String kmAway(AppLocalizations l10n, double distanceMeters) {
    final km = distanceMeters / 1000;
    final s = km >= 10 ? km.toStringAsFixed(0) : km.toStringAsFixed(1);
    return l10n.mapKmAway(s);
  }
}
