import 'dart:developer' as dev;

enum LogLevel { debug, info, warn, error }

class LoggerService {
  static final LoggerService I = LoggerService._();
  LoggerService._();

  void d(String message, {String tag = 'APP'}) =>
      _log(LogLevel.debug, message, tag: tag);

  void i(String message, {String tag = 'APP'}) =>
      _log(LogLevel.info, message, tag: tag);

  void w(String message, {String tag = 'APP'}) =>
      _log(LogLevel.warn, message, tag: tag);

  void e(
    String message, {
    String tag = 'APP',
    Object? error,
    StackTrace? stackTrace,
  }) =>
      _log(
        LogLevel.error,
        message,
        tag: tag,
        error: error,
        stackTrace: stackTrace,
      );

  void _log(
    LogLevel level,
    String message, {
    required String tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    dev.log(
      message,
      name: '[$tag][${level.name.toUpperCase()}]',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
