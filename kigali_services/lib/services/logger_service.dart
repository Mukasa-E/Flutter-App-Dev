import 'package:flutter/foundation.dart';

class LoggerService {
  static const String _prefix = '[Kigali Services]';

  static void debug(String message) {
    debugPrint('$_prefix [DEBUG] $message');
  }

  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    debugPrint('$_prefix [INFO] $message');
    if (error != null) debugPrint('Error: $error');
    if (stackTrace != null) debugPrint('Stack trace: $stackTrace');
  }

  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    debugPrint('$_prefix [WARNING] $message');
    if (error != null) debugPrint('Error: $error');
    if (stackTrace != null) debugPrint('Stack trace: $stackTrace');
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    debugPrint('$_prefix [ERROR] $message');
    if (error != null) debugPrint('Error: $error');
    if (stackTrace != null) debugPrint('Stack trace: $stackTrace');
  }

  static void firestore(
    String operation,
    String collection, [
    String? details,
    dynamic error,
  ]) {
    final msg = '$operation on /$collection ${details ?? ''}';
    if (error != null) {
      error('Firestore: $msg', error);
    } else {
      info('Firestore: $msg');
    }
  }
}
