import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../core/di/service_locator.dart';
import '../features/auth/data/datasources/auth_local_data_source.dart';
import '../features/offer/data/offer_flag_store.dart';
import '../screens/limited_offer_modal.dart';
import '../features/favorites/presentation/bloc/favorites_cubit.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/profile/presentation/bloc/profile_cubit.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../ui/components/pill_tab_bar.dart';
import '../core/theme/app_theme_controller.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    ServiceLocator.instance.get<FavoritesCubit>().load();
    ServiceLocator.instance.get<ProfileCubit>().load();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeShowOffer();
    });
  }

  Future<void> _maybeShowOffer() async {
    final authLocal = ServiceLocator.instance.get<AuthLocalDataSource>();
    final flagStore = ServiceLocator.instance.get<OfferFlagStore>();
    final token = await authLocal.getToken();
    if (token == null) return;
    final shown = await flagStore.isOfferShown();
    if (shown || !mounted) return;
    await showLimitedOfferModal(context);
    await flagStore.markOfferShown();
  }

  void _onTap(int index) {
    if (index == _currentIndex) return;
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final titles = [
      l10n.bottomNavHome,
      l10n.bottomNavProfile,
    ];
    final themeController =
        ServiceLocator.instance.get<AppThemeController>();
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeController.themeMode,
      builder: (context, _, __) {
        return Scaffold(
          backgroundColor: AppColors.bg,
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: IndexedStack(
                    index: _currentIndex,
                    children: _pages,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    AppSpacing.lg,
                  ),
                  child: SafeArea(
                    top: false,
                    child: PillTabBar(
                      items: [
                        PillTabItem(
                          label: titles[0],
                          iconAsset: 'assets/icons/home.svg',
                        ),
                        PillTabItem(
                          label: titles[1],
                          iconAsset: 'assets/icons/profile.svg',
                        ),
                      ],
                      selectedIndex: _currentIndex,
                      onChange: _onTap,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
