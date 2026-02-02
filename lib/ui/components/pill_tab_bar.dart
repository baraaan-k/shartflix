import 'package:flutter/material.dart';

import '../../core/theme/theme_binding.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';
import '../primitives/app_icon.dart';
import '../primitives/app_text.dart';

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
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        color: AppColors.surface.withAlpha(170),
        border: Border.all(color: AppColors.textPrimary.withAlpha(20)),
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
                  boxShadow: selected ? AppShadows.redGlow : const [],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppIcon(
                      item.iconAsset,
                      size: AppSpacing.iconMd,
                      color: selected ? Colors.white : AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    AppText(
                      item.label,
                      style: AppTextStyle.caption,
                      color: selected ? Colors.white : AppColors.textSecondary,
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
