import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'router/app_router.dart';
import '../theme/app_theme.dart';
import '../core/di/service_locator.dart';
import '../core/localization/app_locale_controller.dart';
import '../core/theme/app_theme_controller.dart';
import '../core/theme/theme_binding.dart';
import '../theme/app_colors.dart';
import '../ui/like_burst_overlay.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final localeController = ServiceLocator.instance.get<AppLocaleController>();
    final themeController = ServiceLocator.instance.get<AppThemeController>();
    return ValueListenableBuilder<Locale?>(
      valueListenable: localeController.locale,
      builder: (context, locale, _) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: themeController.themeMode,
          builder: (context, themeMode, __) {
            final brightness = themeMode == ThemeMode.system
                ? PlatformDispatcher.instance.platformBrightness
                : (themeMode == ThemeMode.dark
                    ? Brightness.dark
                    : Brightness.light);
            AppColors.setBrightness(brightness);

            return MaterialApp.router(
              title: 'Shartflix',
              theme: AppTheme.light(),
              darkTheme: AppTheme.dark(),
              themeMode: themeMode,
              routerConfig: appRouter,
              locale: locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              builder: (context, child) => ThemeBinding(
                notifier: themeController.themeMode,
                child: LikeBurstOverlay(
                  child: child ?? const SizedBox.shrink(),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
