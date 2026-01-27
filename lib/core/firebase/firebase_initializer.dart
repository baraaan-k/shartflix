import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import '../logging/logger_service.dart';

class FirebaseInitializer {
  static Future<void>? _initFuture;

  static Future<void> ensureInitialized() {
    return _initFuture ??= _init();
  }

  static Future<void> _init() async {
    try {
      await Firebase.initializeApp();
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance
            .recordError(error, stack, fatal: true);
        return true;
      };
      LoggerService.I.i('Firebase initialized', tag: 'BOOT');
    } catch (e, s) {
      LoggerService.I.e(
        'Firebase init failed',
        tag: 'BOOT',
        error: e,
        stackTrace: s,
      );
    }
  }
}
