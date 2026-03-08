import 'dart:developer' as developer;

/// Lightweight logger with level-based filtering.
class AppLogger {
  AppLogger._();

  static bool _isEnabled = true;

  static void enable() => _isEnabled = true;
  static void disable() => _isEnabled = false;

  static void debug(String message, {String? tag}) {
    if (!_isEnabled) return;
    developer.log(message, name: tag ?? 'DEBUG');
  }

  static void info(String message, {String? tag}) {
    if (!_isEnabled) return;
    developer.log(message, name: tag ?? 'INFO');
  }

  static void warning(String message, {String? tag}) {
    if (!_isEnabled) return;
    developer.log('⚠️ $message', name: tag ?? 'WARN');
  }

  static void error(String message, {Object? error, StackTrace? stackTrace, String? tag}) {
    if (!_isEnabled) return;
    developer.log(
      '❌ $message',
      name: tag ?? 'ERROR',
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void network(String method, String url, {int? statusCode, String? tag}) {
    if (!_isEnabled) return;
    final status = statusCode != null ? ' [$statusCode]' : '';
    developer.log('$method $url$status', name: tag ?? 'HTTP');
  }
}
