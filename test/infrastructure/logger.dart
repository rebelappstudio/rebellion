import 'package:rebellion/utils/logger.dart';

final inMemoryLogger = InMemoryLogger();

class InMemoryLogger extends Logger {
  final List<String> _log = [];

  @override
  void logMessage(String message) {
    super.logMessage(message);
    _log.add(message);
  }

  @override
  void logError(String message) {
    super.logError(message);
    _log.add(message);
  }

  String get output => _log.join('\n');

  void clear() => _log.clear();
}
