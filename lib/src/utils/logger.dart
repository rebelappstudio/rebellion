import 'dart:io';

import 'package:io/ansi.dart';
import 'package:meta/meta.dart';

/// Default instance of [Logger]
@visibleForTesting
Logger logger = Logger();

/// Configure the global [logger] from CLI flags
void configureLogger({required bool verbose}) {
  logger.verbose = verbose;
}

/// Helper class for logging messages
///
/// Can be overridden for testing
class Logger {
  /// Whether verbose pipeline logs are enabled
  bool verbose = false;

  /// Optional override for color enablement (used in tests)
  @visibleForTesting
  bool? colorEnabledOverride;

  /// Optional environment map override (used in tests)
  @visibleForTesting
  Map<String, String>? environmentOverride;

  /// Sink for normal messages (defaults to [stdout])
  @visibleForTesting
  IOSink? outSink;

  /// Sink for error messages (defaults to [stderr])
  @visibleForTesting
  IOSink? errSink;

  bool get _colorEnabled {
    if (colorEnabledOverride != null) return colorEnabledOverride!;
    final environment = environmentOverride ?? Platform.environment;
    if (environment.containsKey('NO_COLOR')) return false;
    return ansiOutputEnabled;
  }

  IOSink get _out => outSink ?? stdout;

  IOSink get _err => errSink ?? stderr;

  String _colorize(AnsiCode code, String message) {
    if (!_colorEnabled) return message;
    return code.wrap(message) ?? message;
  }

  /// Log an error message (stderr, red)
  void logError(String message) {
    _err.writeln(_colorize(red, message));
  }

  /// Log a message (stdout, plain)
  void logMessage(String message) {
    _out.writeln(message);
  }

  /// Log a success message (stdout, green)
  void logSuccess(String message) {
    _out.writeln(_colorize(green, message));
  }

  /// Log a warning message (stdout, yellow)
  void logWarning(String message) {
    _out.writeln(_colorize(yellow, message));
  }

  /// Log a verbose pipeline message (stdout, dim). No-op unless [verbose].
  void logVerbose(String message) {
    if (!verbose) return;
    _out.writeln(_colorize(styleDim, message));
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

/// Log a success message
void logSuccess(String message) {
  logger.logSuccess(message);
}

/// Log a warning message
void logWarning(String message) {
  logger.logWarning(message);
}

/// Log a verbose pipeline message
void logVerbose(String message) {
  logger.logVerbose(message);
}
