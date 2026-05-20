import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography scale — Be Vietnam Pro everywhere.
class AuroraTypography {
  AuroraTypography._();

  static TextTheme textTheme(Color primary, Color secondary) {
    final TextTheme base = GoogleFonts.beVietnamProTextTheme();
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontSize: 96,
        fontWeight: FontWeight.w800,
        height: 1.0,
        letterSpacing: -2,
        color: primary,
      ),
      displayMedium: base.displayMedium?.copyWith(
        fontSize: 72,
        fontWeight: FontWeight.w800,
        height: 1.0,
        letterSpacing: -1.5,
        color: primary,
      ),
      displaySmall: base.displaySmall?.copyWith(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        height: 1.05,
        letterSpacing: -1,
        color: primary,
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        color: primary,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: primary,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: secondary,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: secondary,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: secondary,
      ),
    );
  }

  /// Big distance display on Run screen.
  static TextStyle runDistance({Color color = const Color(0xFFFFFFFF)}) {
    return GoogleFonts.beVietnamPro(
      fontSize: 96,
      fontWeight: FontWeight.w800,
      height: 1.0,
      letterSpacing: -3,
      color: color,
      fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
    );
  }

  /// Secondary metrics on Run screen (pace, time, hr).
  static TextStyle runMetric({Color color = const Color(0xFFFFFFFF)}) {
    return GoogleFonts.beVietnamPro(
      fontSize: 36,
      fontWeight: FontWeight.w700,
      height: 1.1,
      color: color,
      fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
    );
  }
}
