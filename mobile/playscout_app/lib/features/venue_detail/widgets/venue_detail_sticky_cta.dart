import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../design_system/design_tokens.dart';

/// Stitch fixed bottom CTA: "Get Directions".
class VenueDetailStickyCta extends StatelessWidget {
  const VenueDetailStickyCta({
    super.key,
    required this.getDirectionsLabel,
    required this.latitude,
    required this.longitude,
  });

  final String getDirectionsLabel;
  final double latitude;
  final double longitude;

  Future<void> _openDirections() async {
    final u = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude');
    if (await canLaunchUrl(u)) {
      await launchUrl(u, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: PsColors.surface.withValues(alpha: 0.9),
          ),
          child: Padding(
            padding: const EdgeInsets.all(PsSpacing.lg),
            child: Material(
              color: PsColors.errorContainer,
              borderRadius: BorderRadius.circular(9999),
              shadowColor: PsColors.errorContainer.withValues(alpha: 0.35),
              elevation: 8,
              child: InkWell(
                onTap: _openDirections,
                borderRadius: BorderRadius.circular(9999),
                child: SizedBox(
                  height: 64,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.directions_rounded, color: PsColors.onErrorContainer),
                      const SizedBox(width: PsSpacing.sm),
                      Text(
                        getDirectionsLabel,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: PsColors.onErrorContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
