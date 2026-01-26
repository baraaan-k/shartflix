import 'package:flutter/material.dart';

import '../../app/app_shell.dart';
import '../../features/auth/presentation/pages/auth_gate.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';

class AppRoutes {
  static const String authGate = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String shell = '/shell';
}

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.login:
        return MaterialPageRoute<void>(
          builder: (_) => const LoginPage(),
          settings: settings,
        );
      case AppRoutes.register:
        return MaterialPageRoute<void>(
          builder: (_) => const RegisterPage(),
          settings: settings,
        );
      case AppRoutes.shell:
        return MaterialPageRoute<void>(
          builder: (_) => const AppShell(),
          settings: settings,
        );
      case AppRoutes.authGate:
      default:
        return MaterialPageRoute<void>(
          builder: (_) => const AuthGate(),
          settings: settings,
        );
    }
  }
}
