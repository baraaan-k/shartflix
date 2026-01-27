import 'package:flutter/material.dart';

import '../../core/theme/theme_binding.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../primitives/app_icon.dart';

const String _filledHeartSvg = '''
<svg width="24" height="24" viewBox="0 0 24 24" fill="currentColor" xmlns="http://www.w3.org/2000/svg">
<path d="M21 8.25C21 5.765 18.901 3.75 16.312 3.75C14.377 3.75 12.715 4.876 12 6.483C11.285 4.876 9.623 3.75 7.687 3.75C5.1 3.75 3 5.765 3 8.25C3 15.47 12 20.25 12 20.25C12 20.25 21 15.47 21 8.25Z" fill="currentColor"/>
</svg>
''';

class LikeIconPill extends StatelessWidget {
  const LikeIconPill({
    super.key,
    required this.isLiked,
    required this.onTap,
  });

  final bool isLiked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    ThemeBinding.of(context);
    final borderColor = isLiked ? Colors.white : Colors.grey;
    final borderWidth = isLiked ? 0.6 : 0.3;
    final iconColor = isLiked ? AppColors.brandRed : AppColors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        width: 44,
        height: 64,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: borderColor, width: borderWidth),
          boxShadow: const [],
        ),
        child: Center(
          child: isLiked
              ? SvgPicture.string(
                  _filledHeartSvg,
                  width: AppSpacing.iconLg,
                  height: AppSpacing.iconLg,
                  colorFilter: ColorFilter.mode(
                    AppColors.brandRed,
                    BlendMode.srcIn,
                  ),
                )
              : AppIcon(
                  'assets/icons/heart.svg',
                  size: AppSpacing.iconLg,
                  color: iconColor,
                ),
        ),
      ),
    );
  }
}
