import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'design_tokens.dart';

abstract final class PsTheme {
  static ThemeData light() {
    final colorScheme = ColorScheme.light(
      surface: PsColors.surface,
      onSurface: PsColors.onSurface,
      primary: PsColors.primary,
      onPrimary: PsColors.onPrimary,
      primaryContainer: PsColors.primaryContainer,
      onPrimaryContainer: PsColors.onPrimaryContainer,
      secondary: PsColors.secondary,
      onSecondary: PsColors.onSecondary,
      secondaryContainer: PsColors.secondaryContainer,
      onSecondaryContainer: PsColors.onSecondaryContainer,
      tertiary: PsColors.tertiary,
      onTertiary: PsColors.onTertiary,
      error: PsColors.error,
      onError: Colors.white,
      surfaceContainerHighest: PsColors.surfaceContainerHigh,
      outlineVariant: PsColors.outlineVariant,
    );

    final textTheme = TextTheme(
      displayLarge: GoogleFonts.plusJakartaSans(
        fontWeight: FontWeight.w800,
        color: PsColors.onSurface,
      ),
      headlineMedium: GoogleFonts.plusJakartaSans(
        fontWeight: FontWeight.w700,
        color: PsColors.primary,
      ),
      titleMedium: GoogleFonts.beVietnamPro(
        fontWeight: FontWeight.w600,
        color: PsColors.onSurface,
      ),
      bodyLarge: GoogleFonts.beVietnamPro(
        fontWeight: FontWeight.w400,
        color: PsColors.onSurface,
        height: 1.35,
      ),
      bodyMedium: GoogleFonts.beVietnamPro(
        fontWeight: FontWeight.w400,
        color: PsColors.onSurfaceVariant,
        height: 1.35,
      ),
      labelLarge: GoogleFonts.plusJakartaSans(
        fontWeight: FontWeight.w600,
        color: PsColors.onPrimary,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: PsColors.background,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: PsColors.surface.withValues(alpha: 0.82),
        surfaceTintColor: Colors.transparent,
        foregroundColor: PsColors.primary,
        titleTextStyle: textTheme.headlineMedium?.copyWith(fontSize: 20),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: PsColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PsRadii.lg),
        ),
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: PsColors.primary,
          foregroundColor: PsColors.onPrimary,
          padding: const EdgeInsets.symmetric(
            horizontal: PsSpacing.lg,
            vertical: PsSpacing.md,
          ),
          shape: const StadiumBorder(),
          textStyle: textTheme.labelLarge,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: PsColors.surface.withValues(alpha: 0.9),
        indicatorColor: PsColors.primaryContainer,
        labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: PsColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
