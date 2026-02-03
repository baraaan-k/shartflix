import 'package:flutter/material.dart';

import '../../core/theme/theme_binding.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_shadows.dart';
import '../primitives/app_icon.dart';
import '../primitives/app_text.dart';

enum AppButtonVariant { primary, secondary, ghost }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.isDisabled = false,
    this.iconAsset,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool isDisabled;
  final String? iconAsset;

  bool get _enabled => !isDisabled && !isLoading && onPressed != null;

  @override
  Widget build(BuildContext context) {
    ThemeBinding.of(context);
    final bg = _backgroundColor();
    final border = _borderColor();
    final textColor = _textColor();
    final shadows = variant == AppButtonVariant.primary && _enabled
        ? AppShadows.softCard
        : const <BoxShadow>[];

    return Opacity(
      opacity: _enabled ? 1 : 0.6,
      child: GestureDetector(
        onTap: _enabled ? onPressed : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          constraints: const BoxConstraints(
            minHeight: AppSpacing.buttonHeight,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: border),
            boxShadow: shadows,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                SizedBox(
                  height: AppSpacing.iconMd,
                  width: AppSpacing.iconMd,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(textColor),
                  ),
                )
              else if (iconAsset != null) ...[
                AppIcon(iconAsset!, size: AppSpacing.iconMd, color: textColor),
                const SizedBox(width: AppSpacing.sm),
              ],
              AppText(
                label,
                style: AppTextStyle.button,
                color: textColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _backgroundColor() {
    if (!_enabled) return AppColors.surface2;
    switch (variant) {
      case AppButtonVariant.primary:
        return AppColors.brandRed;
      case AppButtonVariant.secondary:
        return AppColors.surface2;
      case AppButtonVariant.ghost:
        return Colors.transparent;
    }
  }

  Color _borderColor() {
    if (!_enabled) return AppColors.border;
    switch (variant) {
      case AppButtonVariant.primary:
        return Colors.transparent;
      case AppButtonVariant.secondary:
        return AppColors.borderSoft;
      case AppButtonVariant.ghost:
        return AppColors.borderSoft;
    }
  }

  Color _textColor() {
    if (!_enabled) return AppColors.muted;
    switch (variant) {
      case AppButtonVariant.primary:
        return Colors.white;
      case AppButtonVariant.secondary:
        return AppColors.textSecondary;
      case AppButtonVariant.ghost:
        return AppColors.textSecondary;
    }
  }
}
