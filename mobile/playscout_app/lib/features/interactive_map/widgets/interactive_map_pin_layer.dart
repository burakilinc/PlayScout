import 'package:flutter/material.dart';

import '../../../design_system/design_tokens.dart';
import '../map_pin_layout.dart';
import '../../home_discover/models/user_location.dart';
import '../../home_discover/models/venue_summary.dart';

class InteractiveMapPinLayer extends StatelessWidget {
  const InteractiveMapPinLayer({
    super.key,
    required this.location,
    required this.venues,
    required this.selectedVenueId,
    required this.onSelectVenue,
    required this.onBackdropTap,
  });

  final UserLocation location;
  final List<VenueSummary> venues;
  final String? selectedVenueId;
  final ValueChanged<String> onSelectVenue;
  final VoidCallback onBackdropTap;

  static const List<IconData> _softIcons = [
    Icons.pedal_bike_rounded,
    Icons.child_care_rounded,
    Icons.restaurant_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final order = List<int>.generate(venues.length, (i) => i)
          ..sort((a, b) {
            final sa = venues[a].id == selectedVenueId;
            final sb = venues[b].id == selectedVenueId;
            if (sa != sb) {
              return sa ? 1 : -1;
            }
            return a.compareTo(b);
          });

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: onBackdropTap,
                child: const ColoredBox(color: Colors.transparent),
              ),
            ),
            for (final i in order)
              _PinMarker(
                venue: venues[i],
                left: w * MapPinLayout.xFraction(venues[i], location),
                top: h * MapPinLayout.yFraction(venues[i], location),
                selected: venues[i].id == selectedVenueId,
                softIcon: _softIcons[i % _softIcons.length],
                softPaletteIndex: i % 3,
                onTap: () => onSelectVenue(venues[i].id),
              ),
          ],
        );
      },
    );
  }
}

class _PinMarker extends StatelessWidget {
  const _PinMarker({
    required this.venue,
    required this.left,
    required this.top,
    required this.selected,
    required this.softIcon,
    required this.softPaletteIndex,
    required this.onTap,
  });

  final VenueSummary venue;
  final double left;
  final double top;
  final bool selected;
  final IconData softIcon;
  final int softPaletteIndex;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (selected) {
      return Positioned(
        left: left,
        top: top,
        child: Transform.translate(
          offset: const Offset(-28, -28),
          child: GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: PsColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: PsColors.surfaceContainerLowest, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF36392B).withValues(alpha: 0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.forest_rounded, color: PsColors.onPrimary, size: 28),
                ),
                Transform.translate(
                  offset: const Offset(0, -6),
                  child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: PsColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF36392B).withValues(alpha: 0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: PsSpacing.sm),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: PsSpacing.md, vertical: PsSpacing.xs),
                    decoration: BoxDecoration(
                      color: PsColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(9999),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF36392B).withValues(alpha: 0.06),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      venue.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: PsColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final (bg, fg) = switch (softPaletteIndex % 3) {
      0 => (PsColors.secondaryContainer, PsColors.secondary),
      1 => (PsColors.primaryContainer, PsColors.primary),
      _ => (PsColors.tertiaryContainer, PsColors.tertiary),
    };

    return Positioned(
      left: left,
      top: top,
      child: Transform.translate(
        offset: const Offset(-20, -20),
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF36392B).withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Icon(softIcon, color: fg, size: 22),
          ),
        ),
      ),
    );
  }
}
