import 'package:go_router/go_router.dart';

import '../../app/app_shell.dart';
import '../../features/auth/presentation/pages/auth_gate.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/home/domain/entities/movie.dart';
import '../../screens/design_system_playground.dart';
import '../../screens/movie_detail_route_page.dart';
import '../../core/navigation/navigation_service.dart';

class AppRouteNames {
  static const String authGate = 'authGate';
  static const String login = 'login';
  static const String register = 'register';
  static const String shell = 'shell';
  static const String home = 'home';
  static const String profile = 'profile';
  static const String movieDetail = 'movieDetail';
  static const String designSystem = 'designSystem';
}

final GoRouter appRouter = GoRouter(
  navigatorKey: NavigationService.rootNavigatorKey,
  routes: [
    GoRoute(
      path: '/',
      name: AppRouteNames.authGate,
      builder: (context, state) => const AuthGate(),
    ),
    GoRoute(
      path: '/login',
      name: AppRouteNames.login,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      name: AppRouteNames.register,
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/shell',
      name: AppRouteNames.shell,
      builder: (context, state) => const AppShell(),
    ),
    GoRoute(
      path: '/profile',
      name: AppRouteNames.profile,
      builder: (context, state) => const AppShell(initialIndex: 1),
    ),
    GoRoute(
      path: '/movie/:id',
      name: AppRouteNames.movieDetail,
      pageBuilder: (context, state) {
        final movie = state.extra is Movie ? state.extra as Movie : null;
        final id = state.pathParameters['id'] ?? '';
        return CustomTransitionPage(
          key: state.pageKey,
          child: MovieDetailRoutePage(
            movie: movie,
            movieId: id,
          ),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          fullscreenDialog: true,
          transitionsBuilder: (context, animation, secondary, child) => child,
        );
      },
    ),
    GoRoute(
      path: '/ds',
      name: AppRouteNames.designSystem,
      builder: (context, state) => const DesignSystemPlayground(),
    ),
  ],
);
