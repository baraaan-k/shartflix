import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../ui/components/app_button.dart';
import '../ui/components/app_text_field.dart';
import '../ui/components/coin_option_card.dart';
import '../ui/components/like_pill_button.dart';
import '../ui/components/pill_tab_bar.dart';
import '../ui/primitives/app_card.dart';
import '../ui/primitives/app_divider.dart';
import '../ui/primitives/app_text.dart';

class DesignSystemPlayground extends StatefulWidget {
  const DesignSystemPlayground({super.key});

  @override
  State<DesignSystemPlayground> createState() => _DesignSystemPlaygroundState();
}

class _DesignSystemPlaygroundState extends State<DesignSystemPlayground> {
  int _selectedTab = 0;
  bool _liked = false;
  bool _selectedCoin = false;

  final _emailController = TextEditingController(text: 'user@shartflix.com');
  final _passwordController = TextEditingController(text: '••••••••');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppText('Design System', style: AppTextStyle.h2),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          const AppText('Buttons', style: AppTextStyle.h1),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              AppButton(
                label: 'Primary',
                onPressed: () {},
                variant: AppButtonVariant.primary,
                iconAsset: 'assets/icons/heart.svg',
              ),
              AppButton(
                label: 'Secondary',
                onPressed: () {},
                variant: AppButtonVariant.secondary,
              ),
              AppButton(
                label: 'Ghost',
                onPressed: () {},
                variant: AppButtonVariant.ghost,
              ),
              const AppButton(
                label: 'Loading',
                onPressed: null,
                isLoading: true,
              ),
              const AppButton(
                label: 'Disabled',
                onPressed: null,
                isDisabled: true,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          const AppText('Text Fields', style: AppTextStyle.h1),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Email',
            hint: 'you@shartflix.com',
            controller: _emailController,
            prefixIconAsset: 'assets/icons/mail.svg',
            helperText: 'We will never share your email.',
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'Focused',
            hint: 'Focus state preview',
            autoFocus: true,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'Password',
            hint: '••••••••',
            controller: _passwordController,
            obscureText: true,
            prefixIconAsset: 'assets/icons/eye.svg',
            errorText: 'Password is too short.',
          ),
          const SizedBox(height: AppSpacing.xxl),
          const AppText('Pill Tab Bar', style: AppTextStyle.h1),
          const SizedBox(height: AppSpacing.md),
          PillTabBar(
            items: const [
              PillTabItem(
                label: 'Home',
                iconAsset: 'assets/icons/home.svg',
              ),
              PillTabItem(
                label: 'Profile',
                iconAsset: 'assets/icons/profile.svg',
              ),
            ],
            selectedIndex: _selectedTab,
            onChange: (index) => setState(() => _selectedTab = index),
          ),
          const SizedBox(height: AppSpacing.xxl),
          const AppText('Like Pill', style: AppTextStyle.h1),
          const SizedBox(height: AppSpacing.md),
          LikePillButton(
            isLiked: _liked,
            onTap: () => setState(() => _liked = !_liked),
          ),
          const SizedBox(height: AppSpacing.xxl),
          const AppText('Coin Option', style: AppTextStyle.h1),
          const SizedBox(height: AppSpacing.md),
          CoinOptionCard(
            title: 'Premium Pack',
            subtitle: 'Get 120 coins to unlock bundles.',
            price: '\$9.99',
            isSelected: _selectedCoin,
            onTap: () => setState(() => _selectedCoin = !_selectedCoin),
          ),
          const SizedBox(height: AppSpacing.xxl),
          const AppText('Card + Divider', style: AppTextStyle.h1),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                AppText('Card Title', style: AppTextStyle.h2),
                SizedBox(height: AppSpacing.sm),
                AppText(
                  'This is a reusable card with border and shadow.',
                  style: AppTextStyle.body,
                  color: AppColors.textSecondary,
                ),
                SizedBox(height: AppSpacing.lg),
                AppDivider(),
                SizedBox(height: AppSpacing.lg),
                AppText('Footer text', style: AppTextStyle.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
