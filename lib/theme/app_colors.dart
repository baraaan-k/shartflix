import 'package:flutter/material.dart';

class AppColorsDark {
  static const Color bg = Color(0xFF0B0B0F);
  static const Color surface = Color(0xFF13131A);
  static const Color surface2 = Color(0xFF1B1B24);
  static const Color textPrimary = Color(0xFFF5F5F7);
  static const Color textSecondary = Color(0xFFB3B3C2);
  static const Color muted = Color(0xFF7A7A8C);
  static const Color border = Color(0xFF262633);
  static const Color borderSoft = Color(0xFF1E1E28);
  static const Color danger = Color(0xFFEF4444);
  static const Color success = Color(0xFF22C55E);
  static const Color brandRed = Color(0xFFE50914);
  static const Color brandRed2 = Color(0xFFB20710);
  static const Color glowRed = Color(0x33E50914);
}

class AppColorsLight {
  static const Color bg = Color(0xFFF6F6FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surface2 = Color(0xFFF1F1F6);
  static const Color textPrimary = Color(0xFF121218);
  static const Color textSecondary = Color(0xFF55556A);
  static const Color muted = Color(0xFF7A7A8C);
  static const Color border = Color(0xFFE2E2EA);
  static const Color borderSoft = Color(0xFFEAEAF2);
  static const Color danger = Color(0xFFEF4444);
  static const Color success = Color(0xFF22C55E);
  static const Color brandRed = Color(0xFFE50914);
  static const Color brandRed2 = Color(0xFFB20710);
  static const Color glowRed = Color(0x33E50914);
}

class AppColors {
  static bool _isDark = true;

  static void setBrightness(Brightness brightness) {
    _isDark = brightness == Brightness.dark;
  }

  static bool get isDark => _isDark;

  static Color get bg => _isDark ? AppColorsDark.bg : AppColorsLight.bg;
  static Color get surface =>
      _isDark ? AppColorsDark.surface : AppColorsLight.surface;
  static Color get surface2 =>
      _isDark ? AppColorsDark.surface2 : AppColorsLight.surface2;
  static Color get textPrimary =>
      _isDark ? AppColorsDark.textPrimary : AppColorsLight.textPrimary;
  static Color get textSecondary =>
      _isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary;
  static Color get muted => _isDark ? AppColorsDark.muted : AppColorsLight.muted;
  static Color get border =>
      _isDark ? AppColorsDark.border : AppColorsLight.border;
  static Color get borderSoft =>
      _isDark ? AppColorsDark.borderSoft : AppColorsLight.borderSoft;
  static Color get danger =>
      _isDark ? AppColorsDark.danger : AppColorsLight.danger;
  static Color get success =>
      _isDark ? AppColorsDark.success : AppColorsLight.success;
  static Color get brandRed =>
      _isDark ? AppColorsDark.brandRed : AppColorsLight.brandRed;
  static Color get brandRed2 =>
      _isDark ? AppColorsDark.brandRed2 : AppColorsLight.brandRed2;
  static Color get glowRed =>
      _isDark ? AppColorsDark.glowRed : AppColorsLight.glowRed;
}
