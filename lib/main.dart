import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'app/app.dart';
import 'core/di/service_locator.dart';
import 'core/install/install_guard.dart';
import 'core/localization/app_locale_controller.dart';
import 'core/logging/logger_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupDependencies();
  await InstallGuard.ensureFreshInstallCleanup();
  await ServiceLocator.instance.get<AppLocaleController>().load();
  await _initFirebaseSafely();
  runApp(const App());
}

Future<void> _initFirebaseSafely() async {
  try {
    await Firebase.initializeApp()
        .timeout(const Duration(seconds: 8));
    FlutterError.onError =
        FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance
          .recordError(error, stack, fatal: true);
      return true;
    };
    LoggerService.I.i('App started', tag: 'BOOT');
  } catch (e) {
    LoggerService.I.e('Firebase init failed', tag: 'BOOT', error: e);
  }
}
