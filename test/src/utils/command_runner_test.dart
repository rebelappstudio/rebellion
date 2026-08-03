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
Analyze ARB file(s) and report issues

Pass one or more ARB files or directories as arguments.

Usage: rebellion analyze <files-or-folders>
-h, --help                Print this usage information.
    --main-locale=<en>    Set the main locale. All localization files are compared to the main locale file for some of the checks
                          (defaults to "en")

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
Sort keys in ARB files

Pass one or more ARB files or directories as arguments.

Usage: rebellion sort <files-or-folders>
-h, --help                Print this usage information.
    --main-locale=<en>    Set the main locale. All localization files are compared to the main locale file for some of the checks
                          (defaults to "en")
    --sorting             How to order keys: alphabetical, alphabetical-reverse, or follow the main locale file
                          [alphabetical (default), alphabetical-reverse, follow-main-file]

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
Find keys present in the main locale file but missing from other ARB files

Pass one or more ARB files or directories as arguments.

Usage: rebellion diff <files-or-folders>
-h, --help                Print this usage information.
    --main-locale=<en>    Set the main locale. All localization files are compared to the main locale file for some of the checks
                          (defaults to "en")
    --output              Where to write missing translations: console or file (*_diff.arb)
                          [file, console (default)]

Run "rebellion help" to see global options.
'''
          .trim(),
    );
  });
}
