import 'dart:async';

import 'package:rebellion/src/utils/command_runner.dart';
import 'package:test/test.dart';

import '../../infrastructure/app_tester.dart';

void main() {
  test('Analyze have description', () {
    AppTester.create();

    var log = '';
    runZoned(
      () => commandRunner.run(['analyze', '--help']),
      zoneSpecification: ZoneSpecification(
        print: (self, parent, zone, line) {
          log += line;
        },
      ),
    );

    expect(
      log,
      '''
Analyze ARB file(s)

Usage: rebellion analyze [arguments]
-h, --help    Print this usage information.

Run "rebellion help" to see global options.
'''
          .trim(),
    );
  });

  test('Sort have description', () {
    AppTester.create();

    var log = '';
    runZoned(
      () => commandRunner.run(['sort', '--help']),
      zoneSpecification: ZoneSpecification(
        print: (self, parent, zone, line) {
          log += line;
        },
      ),
    );

    expect(
      log,
      '''
Sort keys of ARB files

Usage: rebellion sort [arguments]
-h, --help           Print this usage information.
    --main-locale    (defaults to "en")
    --sorting        [alphabetical (default), alphabetical-reverse, follow-main-file]

Run "rebellion help" to see global options.
'''
          .trim(),
    );
  });

  test('Diff have description', () {
    AppTester.create();

    var log = '';
    runZoned(
      () => commandRunner.run(['diff', '--help']),
      zoneSpecification: ZoneSpecification(
        print: (self, parent, zone, line) {
          log += line;
        },
      ),
    );

    expect(
      log,
      '''
Collect missing translations

Usage: rebellion diff [arguments]
-h, --help           Print this usage information.
    --main-locale    (defaults to "en")
    --output         [file, console (default)]

Run "rebellion help" to see global options.
'''
          .trim(),
    );
  });
}
