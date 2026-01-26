import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';
import '../primitives/app_icon.dart';
import '../primitives/app_text.dart';

class CoinOptionCard extends StatelessWidget {
  const CoinOptionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String price;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        constraints: const BoxConstraints(
          minHeight: AppSpacing.coinCardHeight,
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected ? AppColors.brandRed : AppColors.borderSoft,
          ),
          boxShadow: isSelected ? AppShadows.redGlow : AppShadows.softCard,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxHeight = constraints.maxHeight.isFinite
                ? constraints.maxHeight
                : AppSpacing.coinCardHeight;
            final coinSize = maxHeight * 0.7;
            return Stack(
              children: [
                Positioned(
                  right: AppSpacing.md,
                  top: (maxHeight - coinSize) / 2,
                  child: Opacity(
                    opacity: isSelected ? 1 : 0.75,
                    child: SvgPicture.asset(
                      'assets/images/coin.svg',
                      width: coinSize,
                      height: coinSize,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(title, style: AppTextStyle.h2),
                    const SizedBox(height: AppSpacing.xs),
                    AppText(
                      subtitle,
                      style: AppTextStyle.caption,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppText(
                      price,
                      style: AppTextStyle.h1,
                      color: AppColors.brandRed,
                    ),
                  ],
                ),
                if (isSelected)
                  Positioned(
                    right: AppSpacing.sm,
                    top: AppSpacing.sm,
                    child: AppIcon(
                      'assets/icons/check_on.svg',
                      size: AppSpacing.iconMd,
                      color: Colors.white,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
