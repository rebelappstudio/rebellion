import 'package:rebellion/src/utils/logger.dart';

final inMemoryLogger = InMemoryLogger();

class InMemoryLogger extends Logger {
  final List<String> _log = [];

  @override
  void logMessage(String message) {
    _log.add(message);
  }

  @override
  void logError(String message) {
    _log.add(message);
  }

  @override
  void logSuccess(String message) {
    _log.add(message);
  }

  @override
  void logWarning(String message) {
    _log.add(message);
  }

  @override
  void logVerbose(String message) {
    if (!verbose) return;
    _log.add(message);
  }

  String get output => _log.join('\n');

  void clear() {
    _log.clear();
    verbose = false;
  }
}
