import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppShadows {
  static const List<BoxShadow> softCard = [
    BoxShadow(
      color: Color(0x30000000),
      blurRadius: 18,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> redGlow = [
    BoxShadow(
      color: AppColors.glowRed,
      blurRadius: 18,
      offset: Offset(0, 6),
    ),
  ];
}
