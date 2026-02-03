import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTypography {
  static const String fontFamily = 'InstrumentSans';

  static TextStyle _heading(double size) => TextStyle(
        fontFamily: fontFamily,
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle _body(double size, FontWeight weight) => TextStyle(
        fontFamily: fontFamily,
        fontSize: size,
        fontWeight: weight,
        color: AppColors.textPrimary,
      );

  static TextStyle get h1 => TextStyle(
        fontFamily: fontFamily,
        fontSize: 48,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle get h2 => TextStyle(
        fontFamily: fontFamily,
        fontSize: 40,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle get h3 => _heading(32);
  static TextStyle get h4 => _heading(24);
  static TextStyle get h5 => _heading(20);
  static TextStyle get h6 => _heading(18);

  static TextStyle bodyXL([FontWeight weight = FontWeight.w400]) =>
      _body(18, weight);

  static TextStyle bodyL([FontWeight weight = FontWeight.w400]) =>
      _body(16, weight);

  static TextStyle bodyN([FontWeight weight = FontWeight.w400]) =>
      _body(14, weight);

  static TextStyle bodyS([FontWeight weight = FontWeight.w400]) =>
      _body(12, weight);

  static TextStyle bodyXS([FontWeight weight = FontWeight.w400]) =>
      _body(10, weight);

  static TextStyle get body => TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      );

  static TextStyle get caption => TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );

  static TextStyle get button => TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );
}
