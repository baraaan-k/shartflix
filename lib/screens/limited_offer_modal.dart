import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../ui/components/app_button.dart';
import '../ui/primitives/app_card.dart';
import '../ui/primitives/app_icon.dart';
import '../ui/primitives/app_text.dart';

Future<void> showLimitedOfferModal(BuildContext context) async {
  bool isSelected = false;
  final l10n = AppLocalizations.of(context)!;
  final result = await showModalBottomSheet<bool>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withAlpha(166),
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.75,
                    child: AppCard(
                      radius: AppRadius.lg,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      borderColor: Colors.transparent,
                      shadows: const [],
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                          _OfferTag(text: l10n.limitedOfferTitle.toUpperCase()),
                              const Spacer(),
                              IconButton(
                                onPressed: () =>
                                    Navigator.of(sheetContext).pop(false),
                                icon: const Icon(Icons.close),
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          AppText(l10n.limitedOfferHeadline, style: AppTextStyle.h1),
                          const SizedBox(height: AppSpacing.xs),
                          AppText(
                            l10n.limitedOfferHeroSubtitle,
                            style: AppTextStyle.body,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          Expanded(
                            child: _SingleOfferCard(
                              isSelected: isSelected,
                              onTap: () => setModalState(() {
                                isSelected = !isSelected;
                              }),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          _OfferBullet(text: l10n.limitedOfferBenefit1),
                          _OfferBullet(text: l10n.limitedOfferBenefit2),
                          _OfferBullet(text: l10n.limitedOfferBenefit3),
                          const SizedBox(height: AppSpacing.sm),
                          SizedBox(
                            width: double.infinity,
                            child: AppButton(
                              label: l10n.limitedOfferPrimaryCta,
                              onPressed: isSelected
                                  ? () => Navigator.of(sheetContext).pop(true)
                                  : null,
                              isDisabled: !isSelected,
                              variant: AppButtonVariant.primary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          AppText(
                            l10n.limitedOfferDisclaimer,
                            style: AppTextStyle.caption,
                            color: AppColors.muted,
                            align: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
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
    return GestureDetector(
      onTap: onTap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox.expand(
            child: SvgPicture.asset(
              isSelected
                  ? 'assets/images/coinselected.svg'
                  : 'assets/images/coin.svg',
              fit: BoxFit.fitHeight,
            ),
          );
        },
      ),
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
