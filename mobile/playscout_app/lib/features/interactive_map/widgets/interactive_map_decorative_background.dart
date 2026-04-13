import 'package:flutter/material.dart';

import '../../../design_system/design_tokens.dart';
import 'interactive_map_decorative_map_filter.dart';

/// Stitch static map image (full-bleed): partial grayscale + soft opacity — decorative, not navigation UI.
class InteractiveMapDecorativeBackground extends StatelessWidget {
  const InteractiveMapDecorativeBackground({super.key});

  /// Same hero asset as Stitch `Interactive Park Map` screen.
  static const String kStitchMapImageUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuD2bb7Az_AWwlkF3H2szQqflNBdMh6PV3PxVs7LjDKqQAqtSrDujTrQIDCzk-S1BWxkYDbAye7lj0sB5mVshpsnfrd9SoZRJdB7Q21b_Rx_c1MkkglyypsvNM61rC76otW2dhAoX7SFsLOCUdlJHkOFrnwlD2q5oYxJU9fmcNfaXGm51TEVU5WvsO0gnfISeTGhnqh3iMPQuUp2qNp4F3ouc8i0vaXkuRD7uta43pc0PVGtCKiE1L9KA0OWVWfkr2LBgk5bZKY2zkse';

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Opacity(
        opacity: 0.8,
        child: ColorFiltered(
          colorFilter: const ColorFilter.matrix(InteractiveMapDecorativeMapFilter.partialGrayscaleMatrix),
          child: Image.network(
            kStitchMapImageUrl,
            fit: BoxFit.cover,
            alignment: Alignment.center,
            errorBuilder: (context, error, stackTrace) => ColoredBox(
              color: PsColors.surfaceContainerHigh,
              child: Center(
                child: Icon(Icons.map_rounded, size: 48, color: PsColors.primary.withValues(alpha: 0.35)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
