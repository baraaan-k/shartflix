import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';
import '../primitives/app_icon.dart';
import '../primitives/app_text.dart';

class LikePillButton extends StatelessWidget {
  const LikePillButton({
    super.key,
    required this.isLiked,
    required this.onTap,
    this.label = 'Like',
  });

  final bool isLiked;
  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        constraints: const BoxConstraints(
          minHeight: AppSpacing.buttonHeight,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isLiked ? AppColors.brandRed : AppColors.surface2,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: isLiked ? AppColors.brandRed : AppColors.borderSoft,
          ),
          boxShadow: isLiked ? AppShadows.redGlow : const [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcon(
              'assets/icons/heart.svg',
              size: AppSpacing.iconMd,
              color: isLiked ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.sm + AppSpacing.xs),
            AppText(
              label,
              style: AppTextStyle.button,
              color: isLiked ? Colors.white : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
