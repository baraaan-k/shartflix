import 'package:flutter/material.dart';

import '../../core/theme/theme_binding.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PillTabItem {
  const PillTabItem({
    required this.label,
    required this.iconAsset,
  });

  final String label;
  final String iconAsset;
}

class PillTabBar extends StatelessWidget {
  const PillTabBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onChange,
  });

  final List<PillTabItem> items;
  final int selectedIndex;
  final ValueChanged<int> onChange;

  @override
  Widget build(BuildContext context) {
    ThemeBinding.of(context);
    final isDark = AppColors.isDark;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        color: isDark
            ? AppColors.surface.withAlpha(170)
            : AppColors.surface2.withAlpha(230),
        border: Border.all(
          color: isDark
              ? AppColors.textPrimary.withAlpha(20)
              : AppColors.border.withAlpha(80),
        ),
      ),
      child: Row(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final selected = index == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChange(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                constraints: const BoxConstraints(
                  minHeight: AppSpacing.buttonHeight,
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.sm,
                  horizontal: AppSpacing.lg,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  color: selected ? AppColors.brandRed : Colors.transparent,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _TabIcon(
                      asset: item.iconAsset,
                      size: AppSpacing.iconMd,
                      selected: selected,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      item.label,
                      style: AppTypography.bodyS(FontWeight.w700).copyWith(
                        color: selected ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _TabIcon extends StatelessWidget {
  const _TabIcon({
    required this.asset,
    required this.size,
    required this.selected,
  });

  final String asset;
  final double size;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    if (selected) {
      if (asset.endsWith('home.svg')) {
        return SvgPicture.asset(
          'assets/icons/home-fill.svg',
          width: size,
          height: size,
        );
      }
      if (asset.endsWith('profile.svg')) {
        return SvgPicture.asset(
          'assets/icons/profile-fill.svg',
          width: size,
          height: size,
        );
      }
    }
    return SvgPicture.asset(
      asset,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(
        AppColors.textSecondary,
        BlendMode.srcIn,
      ),
    );
  }
}
