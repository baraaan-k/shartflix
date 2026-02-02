import 'package:flutter/material.dart';

import '../../app/app_shell.dart';
import '../../features/auth/presentation/pages/auth_gate.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../screens/design_system_playground.dart';

class AppRoutes {
  static const String authGate = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String profilePhoto = '/profile-photo';
  static const String shell = '/shell';
  static const String designSystem = '/ds';
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
      case AppRoutes.profilePhoto:
        return MaterialPageRoute<void>(
          builder: (_) => const ProfilePhotoUploadPage(),
          settings: settings,
        );
      case AppRoutes.shell:
        return MaterialPageRoute<void>(
          builder: (_) => const AppShell(),
          settings: settings,
        );
      case AppRoutes.designSystem:
        return MaterialPageRoute<void>(
          builder: (_) => const DesignSystemPlayground(),
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
