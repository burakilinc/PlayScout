import 'package:flutter/material.dart';

import '../../../design_system/design_tokens.dart';
import 'interactive_map_decorative_background.dart';

/// Muted wash over the decorative map (loading / error) — not a “real map” chrome.
class InteractiveMapStatusBackdrop extends StatelessWidget {
  const InteractiveMapStatusBackdrop({
    super.key,
    required this.child,
    this.strength = 0.38,
  });

  final Widget child;
  final double strength;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const InteractiveMapDecorativeBackground(),
        Positioned.fill(
          child: ColoredBox(
            color: PsColors.surface.withValues(alpha: strength),
          ),
        ),
        child,
      ],
    );
  }
}
