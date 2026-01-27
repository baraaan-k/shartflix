import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../ui/components/app_button.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_shadows.dart';
import '../ui/primitives/app_card.dart';
import '../ui/primitives/app_icon.dart';
import '../ui/primitives/app_text.dart';

Future<void> showLimitedOfferSheet(BuildContext context) async {
  bool isSelected = true;
  final result = await showModalBottomSheet<bool>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withAlpha(166),
    builder: (sheetContext) {
      final l10n = AppLocalizations.of(sheetContext)!;
      return StatefulBuilder(
        builder: (context, setModalState) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.xl,
              ),
              child: AppCard(
                radius: AppRadius.lg,
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _OfferTag(text: l10n.limitedOfferTitle),
                        const Spacer(),
                        IconButton(
                          onPressed: () =>
                              Navigator.of(sheetContext).pop(false),
                          icon: const Icon(Icons.close),
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppText(
                      'Unlock Premium Now',
                      style: AppTextStyle.h1,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    AppText(
                      'Limited-time deal. Save up to 70%.',
                      style: AppTextStyle.body,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _OfferBullet(text: 'Ad-free experience'),
                    _OfferBullet(text: 'Exclusive content'),
                    _OfferBullet(text: 'Cancel anytime'),
                    const SizedBox(height: AppSpacing.lg),
                    _SingleOfferCard(
                      isSelected: isSelected,
                      onTap: () => setModalState(() {
                        isSelected = !isSelected;
                      }),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      width: double.infinity,
                      child: AppButton(
                        label: 'Get Limited Offer',
                        onPressed: () =>
                            Navigator.of(sheetContext).pop(true),
                        variant: AppButtonVariant.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                      const AppText(
                        'By continuing you agree to Terms.',
                        style: AppTextStyle.caption,
                        color: AppColors.muted,
                        align: TextAlign.center,
                      ),
                    const SizedBox(height: AppSpacing.md),
                    Center(
                      child: AppButton(
                        label: l10n.limitedOfferNotNow,
                        onPressed: () =>
                            Navigator.of(sheetContext).pop(false),
                        variant: AppButtonVariant.ghost,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );

  if (result == true && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.limitedOfferAccepted)),
    );
  }
}

class _OfferBullet extends StatelessWidget {
  const _OfferBullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          const AppIcon(
            'assets/icons/check_on.svg',
            size: AppSpacing.iconMd,
            color: AppColors.success,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: AppText(
              text,
              style: AppTextStyle.body,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _OfferTag extends StatelessWidget {
  const _OfferTag({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      borderColor: AppColors.borderSoft,
      backgroundColor: AppColors.surface2,
      shadows: const [],
      radius: AppRadius.pill,
      child: AppText(
        text,
        style: AppTextStyle.caption,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _SingleOfferCard extends StatelessWidget {
  const _SingleOfferCard({
    required this.isSelected,
    required this.onTap,
  });

  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected ? Colors.white : AppColors.borderSoft;
    final borderWidth = isSelected ? 2.0 : 1.0;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: borderColor, width: borderWidth),
              boxShadow: isSelected ? AppShadows.softCard : const [],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      AppText('Premium Pack', style: AppTextStyle.h2),
                      SizedBox(height: AppSpacing.xs),
                      AppText(
                        '300 Coins + bonus',
                        style: AppTextStyle.caption,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(height: AppSpacing.md),
                      AppText(
                        '\$19.99',
                        style: AppTextStyle.h1,
                        color: AppColors.brandRed,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                _CoinSticker(isSelected: isSelected),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CoinSticker extends StatelessWidget {
  const _CoinSticker({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(
          color: isSelected ? Colors.white : Colors.transparent,
          width: 2,
        ),
      ),
      child: SvgPicture.asset(
        'assets/images/coin.svg',
        fit: BoxFit.contain,
      ),
    );
  }
}
