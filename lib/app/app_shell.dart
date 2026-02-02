import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../core/di/service_locator.dart';
import '../features/favorites/presentation/bloc/favorites_cubit.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/profile/presentation/bloc/profile_cubit.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../ui/components/pill_tab_bar.dart';
import '../core/theme/app_theme_controller.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _currentIndex;

  final List<Widget> _pages = const [
    HomePage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    ServiceLocator.instance.get<FavoritesCubit>().load();
    ServiceLocator.instance.get<ProfileCubit>().load();
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
        final bottomInset = MediaQuery.of(context).padding.bottom;
        const tabBarHeight = 72.0;
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            fit: StackFit.expand,
            children: [
              Container(color: AppColors.bg),
              IndexedStack(
                index: _currentIndex,
                children: _pages,
              ),
              Positioned(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                bottom: 0,
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: bottomInset,
                  ),
                  child: SizedBox(
                    height: tabBarHeight,
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
              ),
            ],
          ),
        );
      },
    );
  }
}
