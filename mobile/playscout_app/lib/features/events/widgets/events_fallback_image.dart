import 'package:flutter/material.dart';

import '../../../design_system/design_tokens.dart';

/// Placeholder art when API has no image (Stitch-style soft gradient block).
class EventsFallbackImage extends StatelessWidget {
  const EventsFallbackImage({
    super.key,
    this.aspectRatio = 16 / 10,
    this.height,
    this.icon = Icons.celebration_rounded,
  });

  final double aspectRatio;
  final double? height;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final box = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            PsColors.primary.withValues(alpha: 0.22),
            PsColors.secondary.withValues(alpha: 0.18),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(icon, size: height != null ? (height! * 0.35).clamp(36, 64) : 56, color: PsColors.primary.withValues(alpha: 0.45)),
      ),
    );
    if (height != null) {
      return SizedBox(height: height, width: double.infinity, child: box);
    }
    return AspectRatio(aspectRatio: aspectRatio, child: box);
  }
}
