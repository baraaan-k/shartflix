import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/di/service_locator.dart';
import 'core/install/install_guard.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupDependencies();
  await InstallGuard.ensureFreshInstallCleanup();
  runApp(const App());
}
