import 'package:flutter/material.dart';

import '../../core/theme/theme_binding.dart';
import '../../theme/app_typography.dart';

enum AppTextStyle {
  h1,
  h2,
  h3,
  h4,
  body,
  caption,
  button,
}

class AppText extends StatelessWidget {
  const AppText(
    this.text, {
    super.key,
    this.style = AppTextStyle.body,
    this.color,
    this.maxLines,
    this.overflow,
    this.align,
  });

  final String text;
  final AppTextStyle style;
  final Color? color;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? align;

  TextStyle _resolveStyle() {
    switch (style) {
      case AppTextStyle.h1:
        return AppTypography.h1;
      case AppTextStyle.h2:
        return AppTypography.h2;
      case AppTextStyle.h3:
        return AppTypography.h3;
      case AppTextStyle.h4:
        return AppTypography.h4;
      case AppTextStyle.caption:
        return AppTypography.caption;
      case AppTextStyle.button:
        return AppTypography.button;
      case AppTextStyle.body:
        return AppTypography.body;
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeBinding.of(context);
    final base = _resolveStyle();
    return Text(
      text,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: align,
      style: base.copyWith(color: color ?? base.color),
    );
  }
}
