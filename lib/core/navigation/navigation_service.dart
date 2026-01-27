import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/app_router.dart';

class NavigationService {
  NavigationService();

  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();

  final GlobalKey<NavigatorState> navigatorKey = rootNavigatorKey;

  void goToLogin() {
    final navigator = navigatorKey.currentState;
    if (navigator == null) return;
    final context = navigatorKey.currentContext;
    if (context != null) {
      context.goNamed(AppRouteNames.login);
      return;
    }
    navigator.pushNamedAndRemoveUntil('/login', (route) => false);
  }
}
