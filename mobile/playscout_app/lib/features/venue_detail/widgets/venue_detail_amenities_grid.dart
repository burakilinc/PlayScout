import 'package:flutter/material.dart';
import 'package:playscout_app/l10n/app_localizations.dart';

import '../../../design_system/design_tokens.dart';

typedef _AmenityEntry = ({IconData icon, String label, int stitchOrder});

/// Stitch "What this place offers" grid — only rows for known feature types (no invented amenities).
class VenueDetailAmenitiesGrid extends StatelessWidget {
  const VenueDetailAmenitiesGrid({
    super.key,
    required this.sectionTitle,
    required this.featureTypes,
  });

  final String sectionTitle;
  final List<int> featureTypes;

  /// Subset aligned with Stitch rows (baby changing / Wi‑Fi not in API enum).
  static final Map<int, ({IconData icon, int stitchOrder})> _byType = {
    8: (icon: Icons.stroller_rounded, stitchOrder: 2),
    11: (icon: Icons.local_cafe_rounded, stitchOrder: 3),
    6: (icon: Icons.wb_sunny_rounded, stitchOrder: 5),
    10: (icon: Icons.wc_rounded, stitchOrder: 6),
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    String labelFor(int type) => switch (type) {
          8 => l10n.strollerParking,
          11 => l10n.cafe,
          6 => l10n.shade,
          10 => l10n.restrooms,
          _ => '',
        };
    final entries = <_AmenityEntry>[];
    final seen = <int>{};
    for (final t in featureTypes) {
      final e = _byType[t];
      if (e != null && seen.add(t)) {
        entries.add((icon: e.icon, label: labelFor(t), stitchOrder: e.stitchOrder));
      }
    }
    entries.sort((a, b) => a.stitchOrder.compareTo(b.stitchOrder));
    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          sectionTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: PsColors.onSurface,
          ),
        ),
        const SizedBox(height: PsSpacing.lg),
        LayoutBuilder(
          builder: (context, c) {
            final cross = c.maxWidth >= 480 ? 3 : 2;
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: cross,
              mainAxisSpacing: PsSpacing.lg,
              crossAxisSpacing: PsSpacing.lg,
              childAspectRatio: 3.2,
              children: entries
                  .map(
                    (e) => Row(
                      children: [
                        Icon(e.icon, color: PsColors.tertiary, size: 24),
                        const SizedBox(width: PsSpacing.md),
                        Expanded(
                          child: Text(
                            e.label,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: PsColors.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}
