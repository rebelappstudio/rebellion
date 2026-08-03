import 'dart:io';

import 'package:io/ansi.dart';
import 'package:rebellion/src/utils/logger.dart';
import 'package:test/test.dart';

void main() {
  late _FakeSink out;
  late _FakeSink err;
  late Logger testLogger;

  setUp(() {
    out = _FakeSink();
    err = _FakeSink();
    testLogger = Logger()
      ..outSink = out
      ..errSink = err
      ..colorEnabledOverride = false;
  });

  test('logError writes to stderr', () {
    testLogger.logError('boom');
    expect(err.lines, ['boom']);
    expect(out.lines, isEmpty);
  });

  test('logMessage, logSuccess and logWarning write to stdout', () {
    testLogger.logMessage('hello');
    testLogger.logSuccess('ok');
    testLogger.logWarning('warn');
    expect(out.lines, ['hello', 'ok', 'warn']);
    expect(err.lines, isEmpty);
  });

  test('logVerbose is a no-op unless verbose is enabled', () {
    testLogger.logVerbose('secret');
    expect(out.lines, isEmpty);

    testLogger.verbose = true;
    testLogger.logVerbose('secret');
    expect(out.lines, ['secret']);
  });

  test('colors wrap messages when color is enabled', () {
    testLogger.colorEnabledOverride = true;

    late final String expectedErr;
    late final String expectedOk;
    late final String expectedWarn;
    late final String expectedDbg;

    overrideAnsiOutput(true, () {
      expectedErr = red.wrap('err')!;
      expectedOk = green.wrap('ok')!;
      expectedWarn = yellow.wrap('warn')!;
      expectedDbg = styleDim.wrap('dbg')!;

      testLogger.logError('err');
      testLogger.logSuccess('ok');
      testLogger.logWarning('warn');
      testLogger.verbose = true;
      testLogger.logVerbose('dbg');
    });

    expect(err.lines.single, expectedErr);
    expect(out.lines[0], expectedOk);
    expect(out.lines[1], expectedWarn);
    expect(out.lines[2], expectedDbg);
  });

  test('colorEnabledOverride false skips ANSI even when ansi is on', () {
    testLogger.colorEnabledOverride = false;

    overrideAnsiOutput(true, () {
      testLogger.logError('plain');
    });

    expect(err.lines, ['plain']);
  });

  test('NO_COLOR disables color when override is unset', () {
    testLogger
      ..colorEnabledOverride = null
      ..environmentOverride = const {'NO_COLOR': '1'};

    overrideAnsiOutput(true, () {
      testLogger.logError('plain');
    });

    expect(err.lines, ['plain']);
  });

  test('falls back to ansiOutputEnabled when override is unset', () {
    testLogger
      ..colorEnabledOverride = null
      ..environmentOverride = const {};

    late final String expected;
    overrideAnsiOutput(true, () {
      expected = red.wrap('err')!;
      testLogger.logError('err');
    });

    expect(err.lines.single, expected);
  });

  test('top-level helpers and configureLogger delegate to global logger', () {
    final previous = logger;
    addTearDown(() => logger = previous);

    final out = _FakeSink();
    final err = _FakeSink();
    logger = Logger()
      ..outSink = out
      ..errSink = err
      ..colorEnabledOverride = false;

    configureLogger(verbose: true);
    expect(logger.verbose, isTrue);

    logError('e');
    logMessage('m');
    logSuccess('s');
    logWarning('w');
    logVerbose('v');

    expect(err.lines, ['e']);
    expect(out.lines, ['m', 's', 'w', 'v']);
  });
}

class _FakeSink implements IOSink {
  final List<String> lines = [];

  @override
  void writeln([Object? object = '']) {
    lines.add('$object');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
