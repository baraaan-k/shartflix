import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../ui/components/app_button.dart';
import '../ui/primitives/app_card.dart';
import '../ui/primitives/app_icon.dart';

Future<void> openLimitedOffer(BuildContext context) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    builder: (_) => const LimitedOfferSheet(),
  );

  if (result == true && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.limitedOfferAccepted)),
    );
  }
}

class LimitedOfferSheet extends StatefulWidget {
  const LimitedOfferSheet({super.key});

  @override
  State<LimitedOfferSheet> createState() => _LimitedOfferSheetState();
}

class _LimitedOfferSheetState extends State<LimitedOfferSheet> {
  int _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SizedBox.expand(
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: SafeArea(
            top: false,
            bottom: false,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
                child: Container(
                  color: AppColors.bg,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              center: const Alignment(0.0, -0.90),
                              radius: 1.35,
                              colors: [
                                AppColors.brandRed2.withValues(alpha: 0.55),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              center: const Alignment(0.0, 1.30),
                              radius: 1.35,
                              colors: [
                                AppColors.brandRed2.withValues(alpha: 0.55),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.84,
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: _CloseButton(
                          onTap: () => Navigator.of(context).pop(false),
                        ),
                      ),
                      Text(
                        l10n.limitedOfferTitle,
                        textAlign: TextAlign.center,
                        style: AppTypography.h1.copyWith(fontSize: 28),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.limitedOfferPopupSubtitle,
                        textAlign: TextAlign.center,
                        style: AppTypography.body.copyWith(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 18),
                      _BonusCard(
                        title: l10n.limitedOfferBonusTitle,
                        items: [
                          _BonusItem(
                            icon: 'assets/images/bonus_1.png',
                            label: l10n.limitedOfferBonusPremium,
                          ),
                          _BonusItem(
                            icon: 'assets/images/bonus_2.png',
                            label: l10n.limitedOfferBonusMatches,
                          ),
                          _BonusItem(
                            icon: 'assets/images/bonus_3.png',
                            label: l10n.limitedOfferBonusBoost,
                          ),
                          _BonusItem(
                            icon: 'assets/images/bonus_4.png',
                            label: l10n.limitedOfferBonusLikes,
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        l10n.limitedOfferPackagesTitle,
                        style: AppTypography.h2.copyWith(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 18),
                      LayoutBuilder(
                        builder: (context, c) {
                          final w = c.maxWidth;
                          const gap = 10.0;
                          final cardW = (w - gap * 2) / 3;
                          return Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: cardW,
                                  child: _PackageCard(
                                    badgeText: l10n.limitedOfferBadge10,
                                    oldAmount: l10n.limitedOfferCoin200,
                                    amount: l10n.limitedOfferCoin300,
                                    price: l10n.limitedOfferPrice99,
                                    perText: l10n.limitedOfferPerWeek,
                                    isSelected: _selectedIndex == 0,
                                    onTap: () =>
                                        setState(() => _selectedIndex = 0),
                                  ),
                                ),
                                SizedBox(width: gap),
                                SizedBox(
                                  width: cardW,
                                  child: _PackageCard(
                                    badgeText: l10n.limitedOfferBadge70,
                                    oldAmount: l10n.limitedOfferCoin2000,
                                    amount: l10n.limitedOfferCoin3375,
                                    price: l10n.limitedOfferPrice799,
                                    perText: l10n.limitedOfferPerWeek,
                                    isSelected: _selectedIndex == 1,
                                    onTap: () =>
                                        setState(() => _selectedIndex = 1),
                                  ),
                                ),
                                SizedBox(width: gap),
                                SizedBox(
                                  width: cardW,
                                  child: _PackageCard(
                                    badgeText: l10n.limitedOfferBadge35,
                                    oldAmount: l10n.limitedOfferCoin1000,
                                    amount: l10n.limitedOfferCoin1350,
                                    price: l10n.limitedOfferPrice399,
                                    perText: l10n.limitedOfferPerWeek,
                                    isSelected: _selectedIndex == 2,
                                    onTap: () =>
                                        setState(() => _selectedIndex = 2),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 4,
                          right: 4,
                          bottom: 28,
                        ),
                        child: SizedBox(
                          height: 52,
                          width: double.infinity,
                          child: AppButton(
                            label: l10n.limitedOfferViewAllCta,
                            onPressed: () =>
                                Navigator.of(context).pop(true),
                            variant: AppButtonVariant.primary,
                          ),
                        ),
                      ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.textPrimary.withAlpha(60),
          ),
          color: AppColors.surface.withAlpha(90),
        ),
        child: const Center(
          child: AppIcon(
            'assets/icons/x.svg',
            size: 16,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _BonusCard extends StatelessWidget {
  const _BonusCard({
    required this.title,
    required this.items,
  });

  final String title;
  final List<_BonusItem> items;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AppCard(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          borderColor: Colors.white.withAlpha(50),
          backgroundColor: Colors.white.withAlpha(5),
          shadows: const [],
          radius: AppRadius.lg,
          child: Column(
            children: [
              Text(
                title,
                style: AppTypography.h2.copyWith(fontSize: 22),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: items
                    .map(
                      (item) => Expanded(
                        child: SizedBox(
                          height: 128,
                          child: Column(
                            children: [
                              SizedBox(
                                width: 66,
                                height: 66,
                                child: Image.asset(
                                  item.icon,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              Text(
                                item.label,
                                textAlign: TextAlign.center,
                                style: AppTypography.caption.copyWith(
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BonusItem {
  const _BonusItem({required this.icon, required this.label});

  final String icon;
  final String label;
}

class _PackageCard extends StatelessWidget {
  const _PackageCard({
    required this.badgeText,
    required this.amount,
    required this.price,
    required this.perText,
    required this.isSelected,
    required this.onTap,
    this.oldAmount,
  });

  final String badgeText;
  final String? oldAmount;
  final String amount;
  final String price;
  final String perText;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bgAsset = isSelected
        ? 'assets/images/coinselected_bg.svg'
        : 'assets/images/coin_bg.svg';
    final badgeTint =
        isSelected ? const Color(0xFF6B5BFF) : const Color(0xFFB00020);
    const cardRadius = 21.0;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(cardRadius),
            child: AspectRatio(
              aspectRatio: 116 / 196,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(cardRadius),
                  border: Border.all(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.7)
                        : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: SvgPicture.asset(
                        bgAsset,
                        fit: BoxFit.cover,
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 14, 12, 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (oldAmount != null)
                          Text(
                            oldAmount!,
                            textAlign: TextAlign.center,
                            style: AppTypography.caption.copyWith(
                              color: Colors.white.withAlpha(170),
                              decoration: TextDecoration.lineThrough,
                            ),
                          )
                        else
                          const SizedBox(height: AppSpacing.md),
                          const SizedBox(height: 2),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              amount,
                              style: AppTypography.h1.copyWith(
                                color: Colors.white,
                                fontSize: 28,
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                        Center(
                          child: Text(
                            AppLocalizations.of(context)!.limitedOfferCoinsLabel,
                            textAlign: TextAlign.center,
                            style: AppTypography.body.copyWith(
                              color: Colors.white.withAlpha(200),
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 36,
                          height: 1,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(40),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            price,
                            textAlign: TextAlign.center,
                            style: AppTypography.h2.copyWith(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Center(
                          child: Text(
                            perText,
                            textAlign: TextAlign.center,
                            style: AppTypography.caption.copyWith(
                              color: Colors.white.withAlpha(200),
                              fontSize: 12,
                            ),
                          ),
                        ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: -12,
            left: 0,
            right: 0,
            child: Center(
              child: TopBadge(
                text: badgeText,
                tint: badgeTint,
                isSelected: isSelected,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TopBadge extends StatelessWidget {
  const TopBadge({
    super.key,
    required this.text,
    required this.tint,
    required this.isSelected,
  });

  final String text;
  final Color tint;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                tint.withValues(alpha: 0.65),
                tint.withValues(alpha: 0.35),
              ],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: isSelected ? 0.7 : 0.28),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 14,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
              height: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}
