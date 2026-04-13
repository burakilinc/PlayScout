import 'package:flutter/material.dart';
import 'package:playscout_app/l10n/app_localizations.dart';

import '../../../design_system/design_tokens.dart';
import '../models/venue_nearby_criteria.dart';

class FilterOptionsDistanceSection extends StatelessWidget {
  const FilterOptionsDistanceSection({
    super.key,
    required this.radiusKm,
    required this.onChanged,
  });

  final double radiusKm;
  final ValueChanged<double> onChanged;

  String _badgeLabel(AppLocalizations l10n) {
    final v = (radiusKm * 2).round() / 2;
    final s = v == v.roundToDouble() ? '${v.toInt()}' : v.toStringAsFixed(1);
    return l10n.formatDistanceKm(s);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.filterDistanceTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: PsColors.onSurface,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: PsColors.primaryContainer,
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Text(
                _badgeLabel(l10n),
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: PsColors.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: PsSpacing.md),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: PsSpacing.md),
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 8,
              activeTrackColor: PsColors.primary,
              inactiveTrackColor: PsColors.surfaceContainerHigh,
              thumbShape: const _FilterSliderThumbShape(),
              overlayShape: SliderComponentShape.noOverlay,
            ),
            child: Slider(
              value: radiusKm.clamp(VenueNearbyCriteria.minRadiusKm, VenueNearbyCriteria.maxRadiusKm),
              min: VenueNearbyCriteria.minRadiusKm,
              max: VenueNearbyCriteria.maxRadiusKm,
              divisions: 19,
              onChanged: onChanged,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.filterDistanceHalfKm,
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
                color: PsColors.onSurfaceVariant,
              ),
            ),
            Text(
              l10n.filterDistanceTenKm,
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
                color: PsColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FilterSliderThumbShape extends SliderComponentShape {
  const _FilterSliderThumbShape();

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(32, 32);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    const r = 12.0;
    canvas.drawCircle(center, r + 2, Paint()..color = Colors.white);
    canvas.drawCircle(center, r, Paint()..color = PsColors.primary);
  }
}
