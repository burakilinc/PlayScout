import 'package:flutter/material.dart';

/// Tokens derived from Stitch `tailwind.config` + `meadow_sky/DESIGN.md` (Organic Sanctuary).
abstract final class PsColors {
  static const Color background = Color(0xFFFEFDF1);
  static const Color surface = Color(0xFFFEFDF1);
  static const Color surfaceContainer = Color(0xFFF4F5E4);
  static const Color surfaceContainerLow = Color(0xFFFAFAEB);
  static const Color surfaceContainerHigh = Color(0xFFEEEFDD);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);

  static const Color primary = Color(0xFF2B6B84);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFA3E0FC);
  static const Color onPrimaryContainer = Color(0xFF005169);

  static const Color secondary = Color(0xFF327053);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFB0F1CC);
  static const Color onSecondaryContainer = Color(0xFF1C5C41);

  static const Color tertiary = Color(0xFF955419);
  static const Color onTertiary = Color(0xFFFFFFFF);

  static const Color error = Color(0xFFAF3D3B);
  static const Color errorContainer = Color(0xFFFA746F);

  static const Color onSurface = Color(0xFF36392B);
  static const Color onSurfaceVariant = Color(0xFF636656);
  static const Color outlineVariant = Color(0xFFB9BBA8);

  /// Stitch / M3 tokens used on Home & Discover (Organic Sanctuary).
  static const Color secondaryFixed = Color(0xFFB0F1CC);
  static const Color onSecondaryFixed = Color(0xFF004930);
  static const Color onSecondaryFixedVariant = Color(0xFF28674A);
  static const Color tertiaryContainer = Color(0xFFFFAB69);
  static const Color onTertiaryContainer = Color(0xFF5D2E00);
  static const Color surfaceContainerHighest = Color(0xFFE8EAD5);
  static const Color surfaceVariant = Color(0xFFE8EAD5);
  static const Color onErrorContainer = Color(0xFF6E0A12);
  static const Color primaryContainerGradientEnd = Color(0xFFDCEDF5);
  static const Color secondaryDim = Color(0xFF246347);

  /// Park shadow: #36392b @ 6% opacity, blur 24–32, offset Y 8.
  static List<BoxShadow> parkShadow({double blur = 28, double y = 8}) => [
        BoxShadow(
          color: const Color(0xFF36392B).withValues(alpha: 0.06),
          blurRadius: blur,
          offset: Offset(0, y),
        ),
      ];
}

abstract final class PsRadii {
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 32;
  static const double xl = 48;
}

abstract final class PsSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}
