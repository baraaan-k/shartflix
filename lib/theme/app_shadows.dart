import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppShadows {
  static List<BoxShadow> get softCard => const [
        BoxShadow(
          color: Color(0x30000000),
          blurRadius: 18,
          offset: Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get redGlow => [
        BoxShadow(
          color: AppColors.glowRed,
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ];
}
