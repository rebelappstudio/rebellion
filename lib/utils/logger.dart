import 'package:meta/meta.dart';

@visibleForTesting
Logger logger = Logger();

class Logger {
  void logError(String message) {
    print(message);
  }

  void logMessage(String message) {
    print(message);
  }
}

void logError(String message) {
  logger.logError(message);
}

void logMessage(String message) {
  logger.logMessage(message);
}
