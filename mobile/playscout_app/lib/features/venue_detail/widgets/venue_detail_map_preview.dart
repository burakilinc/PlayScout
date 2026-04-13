import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../design_system/design_tokens.dart';
import '../map/osm_static_map_image_url.dart';

/// Stitch map preview: image + gradient overlay + bottom row (no fake address text).
class VenueDetailMapPreview extends StatelessWidget {
  const VenueDetailMapPreview({
    super.key,
    required this.openInMapsLabel,
    required this.latitude,
    required this.longitude,
  });

  final String openInMapsLabel;
  final double latitude;
  final double longitude;

  Uri _mapsUri() => Uri.parse('https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');

  Future<void> _openMaps() async {
    final u = _mapsUri();
    if (await canLaunchUrl(u)) {
      await launchUrl(u, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mapUrl = osmStaticMapImageUrl(latitude: latitude, longitude: longitude);
    return SizedBox(
      height: 192,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(PsRadii.md),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              mapUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => ColoredBox(
                color: PsColors.surfaceContainerHigh,
                child: Center(
                  child: Icon(Icons.map_rounded, size: 40, color: PsColors.primary.withValues(alpha: 0.5)),
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.4),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Positioned(
              left: PsSpacing.md,
              right: PsSpacing.md,
              bottom: PsSpacing.md,
              child: Row(
                children: [
                  const Spacer(),
                  Material(
                    color: PsColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(9999),
                    elevation: 4,
                    child: InkWell(
                      onTap: _openMaps,
                      borderRadius: BorderRadius.circular(9999),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: PsSpacing.md, vertical: PsSpacing.sm),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.map_rounded, size: 16, color: PsColors.onSurface),
                            const SizedBox(width: PsSpacing.sm),
                            Text(
                              openInMapsLabel,
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                                color: PsColors.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
