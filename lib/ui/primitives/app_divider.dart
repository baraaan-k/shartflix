import 'package:flutter/material.dart';

import '../../core/theme/theme_binding.dart';
import '../../theme/app_colors.dart';

class AppDivider extends StatelessWidget {
  const AppDivider({super.key, this.height = 1});

  final double height;

  @override
  Widget build(BuildContext context) {
    ThemeBinding.of(context);
    return Container(
      height: height,
      color: AppColors.borderSoft,
    );
  }
}
