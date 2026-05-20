import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:runvie/core/theme/colors.dart';
import 'package:runvie/core/theme/spacing.dart';
import 'package:runvie/core/theme/typography.dart';

/// Aurora Energy theme builder.
class AuroraTheme {
  AuroraTheme._();

  static ThemeData light() => _build(
        brightness: Brightness.light,
        scaffold: AuroraColors.bgLight,
        surface: AuroraColors.surfaceLight,
        textPrimary: AuroraColors.textPrimaryLight,
        textSecondary: AuroraColors.textSecondaryLight,
      );

  static ThemeData dark() => _build(
        brightness: Brightness.dark,
        scaffold: AuroraColors.bgDark,
        surface: AuroraColors.surfaceDark,
        textPrimary: AuroraColors.textPrimaryDark,
        textSecondary: AuroraColors.textSecondaryDark,
      );

  /// Pure black OLED variant used on Run screen.
  static ThemeData black() => _build(
        brightness: Brightness.dark,
        scaffold: AuroraColors.bgBlack,
        surface: AuroraColors.surfaceBlack,
        textPrimary: AuroraColors.textPrimaryDark,
        textSecondary: AuroraColors.textSecondaryDark,
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color scaffold,
    required Color surface,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final ColorScheme scheme = ColorScheme(
      brightness: brightness,
      primary: AuroraColors.coralPrimary,
      onPrimary: Colors.white,
      secondary: AuroraColors.mintSecondary,
      onSecondary: Colors.white,
      tertiary: AuroraColors.lavenderTertiary,
      onTertiary: Colors.white,
      error: AuroraColors.error,
      onError: Colors.white,
      surface: surface,
      onSurface: textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffold,
      textTheme: AuroraTypography.textTheme(textPrimary, textSecondary),
      appBarTheme: AppBarTheme(
        backgroundColor: scaffold,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AuroraColors.coralPrimary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(AuroraSpacing.primaryButtonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AuroraSpacing.radiusLg),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          minimumSize: const Size.fromHeight(AuroraSpacing.primaryButtonHeight),
          side: BorderSide(color: textSecondary.withValues(alpha: 0.3)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AuroraSpacing.radiusLg),
          ),
        ),
      ),
      cardTheme: CardTheme(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AuroraSpacing.radiusXl),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AuroraSpacing.lg,
          vertical: AuroraSpacing.lg,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AuroraSpacing.radiusLg),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AuroraSpacing.radiusLg),
          borderSide: const BorderSide(
            color: AuroraColors.coralPrimary,
            width: 2,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: AuroraColors.coralPrimary.withValues(alpha: 0.15),
        labelTextStyle: WidgetStatePropertyAll<TextStyle>(
          TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: textSecondary.withValues(alpha: 0.12),
        thickness: 1,
        space: 1,
      ),
    );
  }
}
