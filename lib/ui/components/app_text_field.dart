import 'package:flutter/material.dart';

import '../../core/theme/theme_binding.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_shadows.dart';
import '../primitives/app_icon.dart';
import '../primitives/app_text.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.prefixIconAsset,
    this.errorText,
    this.helperText,
    this.enabled = true,
    this.autoFocus = false,
    this.validator,
    this.autovalidateMode,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.onChanged,
  });

  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final String? prefixIconAsset;
  final String? errorText;
  final String? helperText;
  final bool enabled;
  final bool autoFocus;
  final FormFieldValidator<String>? validator;
  final AutovalidateMode? autovalidateMode;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final ValueChanged<String>? onChanged;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscure;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeBinding.of(context);
    return FormField<String>(
      initialValue: widget.controller?.text ?? '',
      validator: widget.validator,
      autovalidateMode: widget.autovalidateMode,
      builder: (field) {
        final fieldError = field.errorText;
        final hasError =
            (fieldError != null && fieldError.isNotEmpty) ||
                (widget.errorText != null && widget.errorText!.isNotEmpty);
        final isFocused = _focusNode.hasFocus;
        final borderColor = !widget.enabled
            ? AppColors.borderSoft
            : hasError
                ? AppColors.danger
                : isFocused
                    ? AppColors.brandRed
                    : AppColors.borderSoft;
    final textColor =
        widget.enabled ? AppColors.textPrimary : AppColors.textSecondary;
    final iconColor = widget.enabled
        ? AppColors.textSecondary
        : AppColors.textSecondary.withAlpha(153);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.label != null) ...[
              AppText(widget.label!, style: AppTextStyle.caption),
              const SizedBox(height: AppSpacing.xs),
            ],
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: AppSpacing.fieldHeight,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: widget.enabled ? AppColors.surface : AppColors.surface2,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(color: borderColor),
                boxShadow: isFocused && !hasError && widget.enabled
                    ? AppShadows.redGlow
                    : const [],
              ),
              child: Row(
                children: [
                  if (widget.prefixIconAsset != null) ...[
                    AppIcon(
                      widget.prefixIconAsset!,
                      size: AppSpacing.iconMd,
                      color: iconColor,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Expanded(
                    child: TextField(
                      controller: widget.controller,
                      focusNode: _focusNode,
                      obscureText: _obscure,
                      enabled: widget.enabled,
                      autofocus: widget.autoFocus,
                      keyboardType: widget.keyboardType,
                      textCapitalization: widget.textCapitalization,
                      textAlignVertical: TextAlignVertical.center,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration.collapsed(
                        hintText: widget.hint,
                        hintStyle: TextStyle(color: AppColors.muted),
                      ),
                      onChanged: (value) {
                        field.didChange(value);
                        widget.onChanged?.call(value);
                      },
                    ),
                  ),
                  if (widget.obscureText)
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => setState(() => _obscure = !_obscure),
                      child: Padding(
                        padding: const EdgeInsets.only(left: AppSpacing.sm),
                        child: AppIcon(
                          _obscure
                              ? 'assets/icons/eye.svg'
                              : 'assets/icons/eye_off.svg',
                          size: AppSpacing.iconMd,
                          color: iconColor,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (fieldError != null && fieldError.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              AppText(
                fieldError,
                style: AppTextStyle.caption,
                color: AppColors.danger,
              ),
            ] else if (widget.errorText != null &&
                widget.errorText!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              AppText(
                widget.errorText!,
                style: AppTextStyle.caption,
                color: AppColors.danger,
              ),
            ] else if (widget.helperText != null) ...[
              const SizedBox(height: AppSpacing.xs),
              AppText(
                widget.helperText!,
                style: AppTextStyle.caption,
                color: AppColors.muted,
              ),
            ],
          ],
        );
      },
    );
  }
}
