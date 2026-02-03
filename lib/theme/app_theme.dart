import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData dark() {
    final colorScheme = const ColorScheme.dark(
      primary: AppColorsDark.brandRed,
      secondary: AppColorsDark.brandRed2,
      surface: AppColorsDark.bg,
      error: AppColorsDark.danger,
      onPrimary: Colors.white,
      onSurface: AppColorsDark.textPrimary,
    );

    return ThemeData(
      brightness: Brightness.dark,
      fontFamily: AppTypography.fontFamily,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColorsDark.bg,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColorsDark.bg,
        elevation: 0,
        foregroundColor: AppColorsDark.textPrimary,
      ),
      textTheme: TextTheme(
        headlineLarge: AppTypography.h1,
        headlineMedium: AppTypography.h2,
        bodyMedium: AppTypography.body,
        labelLarge: AppTypography.button,
        bodySmall: AppTypography.caption,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: false,
        fillColor: Colors.transparent,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        isDense: true,
        isCollapsed: true,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  static ThemeData light() {
    final colorScheme = const ColorScheme.light(
      primary: AppColorsLight.brandRed,
      secondary: AppColorsLight.brandRed2,
      surface: AppColorsLight.bg,
      error: AppColorsLight.danger,
      onPrimary: Colors.white,
      onSurface: AppColorsLight.textPrimary,
    );

    return ThemeData(
      brightness: Brightness.light,
      fontFamily: AppTypography.fontFamily,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColorsLight.bg,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColorsLight.bg,
        elevation: 0,
        foregroundColor: AppColorsLight.textPrimary,
      ),
      textTheme: TextTheme(
        headlineLarge: AppTypography.h1,
        headlineMedium: AppTypography.h2,
        bodyMedium: AppTypography.body,
        labelLarge: AppTypography.button,
        bodySmall: AppTypography.caption,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: false,
        fillColor: Colors.transparent,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        isDense: true,
        isCollapsed: true,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}
