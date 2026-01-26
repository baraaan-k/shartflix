import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../core/router/app_router.dart';
import '../features/auth/presentation/pages/auth_gate.dart';
import '../theme/app_theme.dart';
import '../core/di/service_locator.dart';
import '../core/navigation/navigation_service.dart';
import '../core/localization/app_locale_controller.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final localeController = ServiceLocator.instance.get<AppLocaleController>();
    final navigationService =
        ServiceLocator.instance.get<NavigationService>();

    return ValueListenableBuilder<Locale?>(
      valueListenable: localeController.locale,
      builder: (context, locale, _) {
        return MaterialApp(
          title: 'Shartflix',
          theme: AppTheme.dark(),
          home: const AuthGate(),
          onGenerateRoute: AppRouter.onGenerateRoute,
          navigatorKey: navigationService.navigatorKey,
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        );
      },
    );
  }
}
