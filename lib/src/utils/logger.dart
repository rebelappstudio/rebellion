import 'package:meta/meta.dart';

/// Default instance of [Logger]
@visibleForTesting
Logger logger = Logger();

/// Helper class for logging messages
///
/// Can be overridden for testing
class Logger {
  /// Log an error message
  void logError(String message) {
    print(message);
  }

  /// Log a message
  void logMessage(String message) {
    print(message);
  }
}

/// Log an error message
void logError(String message) {
  logger.logError(message);
}

/// Log a message
void logMessage(String message) {
  logger.logMessage(message);
}
