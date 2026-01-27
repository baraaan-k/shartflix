import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/di/service_locator.dart';
import 'core/install/install_guard.dart';
import 'core/localization/app_locale_controller.dart';
import 'core/firebase/firebase_initializer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupDependencies();
  await InstallGuard.ensureFreshInstallCleanup();
  await ServiceLocator.instance.get<AppLocaleController>().load();
  FirebaseInitializer.ensureInitialized();
  runApp(const App());
}
