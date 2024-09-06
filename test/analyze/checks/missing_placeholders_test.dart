import 'package:rebellion/src/analyze/rules/missing_placeholders.dart';
import 'package:rebellion/src/utils/arb_parser/at_key_meta.dart';
import 'package:rebellion/src/utils/rebellion_options.dart';
import 'package:test/test.dart';

import '../../infrastructure/app_tester.dart';
import '../../infrastructure/logger.dart';
import '../../infrastructure/test_arb_files.dart';

void main() {
  setUp(() {
    AppTester.create();
  });

  test('MissingPlaceholders reports no issues when placeholders are present',
      () {
    final issues = MissingPlaceholders().run(
      [
        createFile(
          filepath: 'intl_en.arb',
          isMainFile: true,
          locale: 'en',
          values: {
            'key': 'Hello, {name}!',
            '@key': AtKeyMeta(
              description: null,
              placeholders: [
                AtKeyPlaceholder(
                  name: 'name',
                  type: 'String',
                  example: null,
                )
              ],
            ),
          },
        ),
        createFile(
          filepath: 'intl_es.arb',
          isMainFile: false,
          locale: 'es',
          values: {'key': '¡Hola, {name}!'},
        ),
      ],
      RebellionOptions.empty(),
    );
    expect(issues, isZero);
    expect(inMemoryLogger.output, isEmpty);
  });

  test("MissingPlaceholders ignores @-keys that can't be parsed", () {
    final issues = MissingPlaceholders().run(
      [
        createFile(
          filepath: 'intl_en.arb',
          isMainFile: true,
          locale: 'en',
          values: {
            'key': 'Hello, {name}!',
            '@key': 'foo',
          },
        ),
        createFile(
          filepath: 'intl_es.arb',
          isMainFile: false,
          locale: 'es',
          values: {'key': '¡Hola, {name}!'},
        ),
      ],
      RebellionOptions.empty(),
    );
    expect(issues, isZero);
    expect(inMemoryLogger.output, isEmpty);
  });

  test(
      "MissingPlaceholders reports errors when placeholder are different from what's in the main file",
      () {
    final issues = MissingPlaceholders().run(
      [
        createFile(
          filepath: 'intl_en.arb',
          isMainFile: true,
          locale: 'en',
          values: {
            'key': 'Hello, {name}!',
            '@key': AtKeyMeta(
              description: null,
              placeholders: [
                AtKeyPlaceholder(
                  name: 'name',
                  type: 'String',
                  example: null,
                )
              ],
            ),
          },
        ),
        createFile(
          filepath: 'intl_es.arb',
          isMainFile: false,
          locale: 'es',
          values: {'key': '¡Hola, {nombre}!'},
        ),
      ],
      RebellionOptions.empty(),
    );
    expect(issues, 1);
    expect(
      inMemoryLogger.output,
      'intl_es.arb: key "key" has different placeholders than the main file: [nombre] vs [name]',
    );
  });

  test('MissingPlaceholders reports placeholders without name', () {
    final issues = MissingPlaceholders().run(
      [
        createFile(
          filepath: 'intl_en.arb',
          isMainFile: true,
          locale: 'en',
          values: {
            'key': 'Hello, {name}!',
            '@key': AtKeyMeta(
              description: null,
              placeholders: [
                AtKeyPlaceholder(
                  name: null,
                  type: 'String',
                  example: null,
                )
              ],
            ),
          },
        ),
        createFile(
          filepath: 'intl_es.arb',
          isMainFile: false,
          locale: 'es',
          values: {'key': '¡Hola, {name}!'},
        ),
      ],
      RebellionOptions.empty(),
    );
    expect(issues, 3);
    expect(
      inMemoryLogger.output,
      '''
intl_en.arb: key "@key" is missing placeholders definition
intl_en.arb: key "@key" is missing a placeholder name
intl_es.arb: key "key" has different placeholders than the main file: [name] vs []
'''
          .trim(),
    );
  });

  test('MissingPlaceholders reports missing placeholders', () {
    final issues = MissingPlaceholders().run(
      [
        createFile(
          filepath: 'intl_en.arb',
          isMainFile: true,
          locale: 'en',
          values: {
            'key': 'Hello, {name}!',
            '@key': AtKeyMeta(
              description: null,
              placeholders: [
                AtKeyPlaceholder(
                  name: 'name',
                  type: null,
                  example: null,
                )
              ],
            ),
          },
        ),
        createFile(
          filepath: 'intl_es.arb',
          isMainFile: false,
          locale: 'es',
          values: {'key': '¡Hola, {name}!'},
        ),
      ],
      RebellionOptions.empty(),
    );
    expect(issues, 1);
    expect(
      inMemoryLogger.output,
      'intl_en.arb: key "@key" is missing a placeholder type for "name"',
    );
  });
}
