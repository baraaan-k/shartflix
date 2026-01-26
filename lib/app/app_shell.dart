import 'package:flutter/material.dart';

import '../core/di/service_locator.dart';
import '../features/auth/data/datasources/auth_local_data_source.dart';
import '../features/offer/data/offer_flag_store.dart';
import '../features/offer/presentation/limited_offer_sheet.dart';
import '../features/favorites/presentation/bloc/favorites_cubit.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/profile/presentation/bloc/profile_cubit.dart';
import '../features/profile/presentation/pages/profile_page.dart';

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

  final List<String> _titles = const [
    'Home',
    'Profile',
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
    await showLimitedOfferSheet(context);
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
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
