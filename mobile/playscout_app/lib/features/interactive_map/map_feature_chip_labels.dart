import 'package:playscout_app/l10n/app_localizations.dart';

import '../home_discover/models/venue_summary.dart';

/// Short labels for preview pills (aligned with filter feature type ids).
abstract final class MapFeatureChipLabels {
  static String? forType(AppLocalizations l10n, int id) {
    return switch (id) {
      3 => l10n.indoor,
      4 => l10n.outdoor,
      6 => l10n.shade,
      8 => l10n.strollerFriendly,
      9 => l10n.parking,
      10 => l10n.toilet,
      11 => l10n.foodNearby,
      _ => null,
    };
  }

  /// Up to two known feature labels for the preview card.
  static List<String> previewLabels(AppLocalizations l10n, VenueSummary venue, {int max = 2}) {
    final out = <String>[];
    for (final id in venue.featureTypes) {
      final s = forType(l10n, id);
      if (s != null) {
        out.add(s);
        if (out.length >= max) break;
      }
    }
    return out;
  }
}
