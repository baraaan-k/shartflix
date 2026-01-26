import 'package:flutter/material.dart';

import '../router/app_router.dart';

class NavigationService {
  NavigationService();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  void goToLogin() {
    final navigator = navigatorKey.currentState;
    if (navigator == null) return;
    navigator.pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
  }
}
