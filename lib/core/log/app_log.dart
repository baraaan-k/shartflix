import 'package:flutter/foundation.dart';

class AppLog {
  static void d(String tag, String message) => _log('D', tag, message);
  static void i(String tag, String message) => _log('I', tag, message);
  static void w(String tag, String message) => _log('W', tag, message);
  static void e(String tag, String message) => _log('E', tag, message);

  static void _log(String level, String tag, String message) {
    if (kReleaseMode) return;
    final now = DateTime.now();
    final time =
        '${_two(now.hour)}:${_two(now.minute)}:${_two(now.second)}';
    debugPrint('$time [$level][$tag] $message');
  }

  static String _two(int value) => value.toString().padLeft(2, '0');
}
