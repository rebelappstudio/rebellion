import 'package:rebellion/src/analyze/rules/missing_placeholders.dart';
import 'package:rebellion/src/utils/arb_parser/at_key_meta.dart';
import 'package:rebellion/src/utils/command_runner.dart';
import 'package:rebellion/src/utils/rebellion_options.dart';
import 'package:test/test.dart';

import '../../../infrastructure/app_tester.dart';
import '../../../infrastructure/logger.dart';
import '../../../infrastructure/test_arb_files.dart';

void main() {
  late AppTester tester;

  setUp(() {
    tester = AppTester.create();
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

  test('MissingPlaceholders reports missing placeholders in plural strings',
      () {
    final issues = MissingPlaceholders().run(
      [
        createFile(
          filepath: 'intl_en.arb',
          isMainFile: true,
          locale: 'en',
          values: {
            'key': '{count, plural, one{1 item} other{{count} items}}',
            '@key': AtKeyMeta(
              description: null,
              placeholders: [
                AtKeyPlaceholder(
                  name: 'count',
                  type: 'int',
                  example: null,
                ),
              ],
            ),
          },
        ),
        createFile(
          filepath: 'intl_es.arb',
          isMainFile: false,
          locale: 'es',
          values: {
            'key': '{count, plural, one {1 item} other {x items}}',
          },
        ),
      ],
      RebellionOptions.empty(),
    );
    expect(issues, 1);
    expect(
      inMemoryLogger.output,
      'intl_es.arb: key "key" has different placeholders than the main file: [] vs [count]',
    );
  });

  test('MissingPlaceholders reports missing placeholders in inline strings',
      () {
    final issues = MissingPlaceholders().run(
      [
        createFile(
          filepath: 'intl_en.arb',
          isMainFile: true,
          locale: 'en',
          values: {
            'key':
                'Selected items: {count, plural, one {1 item} other {{count} items}}. Continue?',
            '@key': AtKeyMeta(
              description: null,
              placeholders: [
                AtKeyPlaceholder(
                  name: 'count',
                  type: 'int',
                  example: null,
                ),
              ],
            ),
          },
        ),
        createFile(
          filepath: 'intl_es.arb',
          isMainFile: false,
          locale: 'es',
          values: {
            'key':
                '{count, plural, one{1 elemento} other{{count} elementos}}. ¿Continuar?',
          },
        ),
      ],
      RebellionOptions.empty(),
    );
    expect(issues, 0);
    expect(inMemoryLogger.output, isEmpty);
  });

  test(
      "MissingPlaceholders reports no missing placeholders is string doesn't use placeholders",
      () {
    final issues = MissingPlaceholders().run(
      [
        createFile(
          filepath: 'intl_en.arb',
          isMainFile: true,
          locale: 'en',
          values: {
            'key': '{count, plural, one {1 item} other {X items}}',
            '@key': AtKeyMeta(
              description: null,
              placeholders: [
                AtKeyPlaceholder(
                  name: 'count',
                  type: 'int',
                  example: null,
                ),
              ],
            ),
          },
        ),
        createFile(
          filepath: 'intl_es.arb',
          isMainFile: false,
          locale: 'es',
          values: {
            'key': '{count, plural, one{1 elemento} other{X elementos}}',
          },
        ),
      ],
      RebellionOptions.empty(),
    );
    expect(issues, 0);
    expect(inMemoryLogger.output, isEmpty);
  });

  test(
      "MissingPlaceholders reports no missing placeholders if plural strings have extra placeholders",
      () async {
    tester.setConfigFile(
      '''
rules:
  - missing_placeholders

options:
  main_locale: en

''',
    );
    tester.populateFileSystem({
      'intl_en.arb': '''
{
  "key": "{count, plural, zero{Mode is available} one{{count} games with {stars} remain} two{{count} games with {stars} remain} few{{count} games with {stars} remain} many{{count} games with {stars} remain} other{{count} games with {stars} remain}}",
  "@key": {
    "placeholders": {
      "count": {
        "type": "int"
      },
      "stars": {
        "type": "String"
      }
    }
  }
}
''',
      'intl_ru.arb': '''
{
  "key": "{count, plural, one{Осталась {count} игра и {stars} звезда} few{Остались {count} игры и {stars}} many{Осталось {count} игр и {stars}} other{Осталось {count} игр и {stars}}}"
}
''',
    });

    await commandRunner.run(['analyze', '.']);
    expect(inMemoryLogger.output, 'No issues found');
  });
}
