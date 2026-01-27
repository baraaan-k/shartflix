import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../di/service_locator.dart';
import '../../features/auth/data/datasources/auth_local_data_source.dart';

class InstallGuard {
  static const String _markerName = '.install_marker';

  static Future<void> ensureFreshInstallCleanup() async {
    final file = await _markerFile();
    final exists = await file.exists();
    if (exists) {
      return;
    }
    final authLocal = ServiceLocator.instance.get<AuthLocalDataSource>();
    await authLocal.clearAll();
    await file.create(recursive: true);
  }

  static Future<File> _markerFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_markerName');
  }
}
