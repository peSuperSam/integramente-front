import 'dart:developer' as developer;
import '../config/backend_config.dart';

class AppLogger {
  static const String _appTag = 'IntegraMente';

  /// Log de informação
  static void info(String message, {String? tag}) {
    if (BackendConfig.showLogs) {
      developer.log(
        message,
        name: tag ?? _appTag,
        level: 800, // INFO level
      );
    }
  }

  /// Log de debug
  static void debug(String message, {String? tag}) {
    if (BackendConfig.isDebug) {
      developer.log(
        message,
        name: tag ?? _appTag,
        level: 700, // DEBUG level
      );
    }
  }

  /// Log de warning
  static void warning(String message, {String? tag}) {
    if (BackendConfig.showLogs) {
      developer.log(
        message,
        name: tag ?? _appTag,
        level: 900, // WARNING level
      );
    }
  }

  /// Log de erro
  static void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      name: tag ?? _appTag,
      level: 1000, // ERROR level
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log específico para backend
  static void backend(String message) {
    info(message, tag: '${_appTag}_Backend');
  }

  /// Log específico para API
  static void api(String message) {
    debug(message, tag: '${_appTag}_API');
  }

  /// Log de configuração
  static void config(String message) {
    info(message, tag: '${_appTag}_Config');
  }
}
