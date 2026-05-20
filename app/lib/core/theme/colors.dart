import 'package:flutter/material.dart';

/// Aurora Energy palette for RunVie.
///
/// Coral as primary energy color, mint as recovery/secondary,
/// lavender as accent for premium / AI features.
class AuroraColors {
  AuroraColors._();

  // Primary brand
  static const Color coralPrimary = Color(0xFFFF5A36);
  static const Color coralLight = Color(0xFFFF8567);
  static const Color coralDark = Color(0xFFCC3F1F);

  // Secondary
  static const Color mintSecondary = Color(0xFF00D4A8);
  static const Color mintLight = Color(0xFF4FE6C7);
  static const Color mintDark = Color(0xFF00A082);

  // Tertiary
  static const Color lavenderTertiary = Color(0xFF7B5CFF);
  static const Color lavenderLight = Color(0xFFA88FFF);
  static const Color lavenderDark = Color(0xFF5A3FCC);

  // Backgrounds — light
  static const Color bgLight = Color(0xFFFAFAFA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceLightAlt = Color(0xFFF2F2F4);

  // Backgrounds — dark
  static const Color bgDark = Color(0xFF0F1014);
  static const Color surfaceDark = Color(0xFF1A1B21);
  static const Color surfaceDarkAlt = Color(0xFF24262E);

  // Pure black variant (used on Run screen for OLED)
  static const Color bgBlack = Color(0xFF000000);
  static const Color surfaceBlack = Color(0xFF0A0A0A);

  // Text
  static const Color textPrimaryLight = Color(0xFF101218);
  static const Color textSecondaryLight = Color(0xFF5A5E6B);
  static const Color textTertiaryLight = Color(0xFF9097A4);

  static const Color textPrimaryDark = Color(0xFFF5F6F8);
  static const Color textSecondaryDark = Color(0xFFB4B8C4);
  static const Color textTertiaryDark = Color(0xFF7A7F8C);

  // Semantic
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Heart rate zones (5)
  static const Color hrZone1 = Color(0xFF60A5FA); // very light - recovery
  static const Color hrZone2 = Color(0xFF34D399); // light - endurance
  static const Color hrZone3 = Color(0xFFFBBF24); // moderate - tempo
  static const Color hrZone4 = Color(0xFFF97316); // hard - threshold
  static const Color hrZone5 = Color(0xFFDC2626); // max - vo2max

  // Aurora gradient (used for premium hero / streak ring)
  static const List<Color> auroraGradient = <Color>[
    coralPrimary,
    lavenderTertiary,
    mintSecondary,
  ];

  static const LinearGradient auroraLinear = LinearGradient(
    colors: auroraGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
