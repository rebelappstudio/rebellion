import 'package:rebellion/src/analyze/rules/rule.dart';
import 'package:rebellion/src/utils/arb_parser/arb_file.dart';
import 'package:rebellion/src/utils/arb_parser/arb_parser.dart';
import 'package:rebellion/src/utils/arb_parser/at_key_meta.dart';
import 'package:test/test.dart';

import '../../../infrastructure/app_tester.dart';
import '../../../infrastructure/logger.dart';

void main() {
  test('parseArbFile throws an exception when ARB is not a valid JSON',
      () async {
    final tester = AppTester.create();
    tester.populateFileSystem({
      'strings_en.arb': '{;}',
    });

    expect(
      () => parseArbFile(
        ArbFile(
          filepath: 'strings_en.arb',
          filenameLocale: 'en',
          isMainFile: true,
        ),
      ),
      throwsA(isA<FormatException>()),
    );
    expect(
      inMemoryLogger.output,
      'strings_en.arb: file content is not a valid JSON',
    );
  });

  test('parseArbFile throws an exception when JSON contains an array', () {
    final tester = AppTester.create();
    tester.populateFileSystem({
      'strings_en.arb': '{"key": []}',
    });

    expect(
      () => parseArbFile(
        ArbFile(
          filepath: 'strings_en.arb',
          filenameLocale: 'en',
          isMainFile: true,
        ),
      ),
      throwsA(isA<FormatException>()),
    );
    expect(
      inMemoryLogger.output,
      'strings_en.arb: ARB must not contain top-level arrays',
    );
  });

  test('parseArbFile can parse placeholder array', () {
    final tester = AppTester.create();
    tester.populateFileSystem({
      'strings_en.arb': '''
{
  "key": "Hi, {name}",
  "@key": {
    "description": "Greeting",
    "placeholders": {
      "name": {
        "type": "String",
        "example": "Hi, John",
        "something": ["a", "b"]
      }
    }
  }
}
''',
    });

    final parsedFile = parseArbFile(
      ArbFile(
        filepath: 'strings_en.arb',
        filenameLocale: 'en',
        isMainFile: true,
      ),
    );
    expect(
      parsedFile.content,
      {
        'key': 'Hi, {name}',
        '@key': AtKeyMeta(
          description: 'Greeting',
          ignoredRulesRaw: [],
          placeholders: [
            AtKeyPlaceholder(
              name: 'name',
              type: 'String',
              example: 'Hi, John',
            ),
          ],
        ),
      },
    );
    expect(inMemoryLogger.output, isEmpty);
  });

  test('parseArbFile can parse key meta', () {
    final tester = AppTester.create();
    tester.populateFileSystem({
      'strings_en.arb': '''
{
  "key": "Count: {count}, color: {color}",
  "@key": {
    "description": "Number of cars",
    "placeholders": {
      "count": {
        "type": "int",
        "example": "Count: 2"
      },
      "color": {}
    }
  }
}
''',
    });

    final arbFile = ArbFile(
      filepath: 'strings_en.arb',
      filenameLocale: 'en',
      isMainFile: true,
    );
    final parsedArbFile = parseArbFile(arbFile);

    expect(parsedArbFile.file, arbFile);
    expect(parsedArbFile.keys, ['key', '@key']);
    expect(parsedArbFile.rawKeys, ['key', '@key']);
    expect(parsedArbFile.content['key'], 'Count: {count}, color: {color}');
    expect(
      parsedArbFile.content['@key'],
      AtKeyMeta(
        description: 'Number of cars',
        ignoredRulesRaw: [],
        placeholders: [
          AtKeyPlaceholder(
            name: 'count',
            type: 'int',
            example: 'Count: 2',
          ),
          AtKeyPlaceholder(
            name: 'color',
            type: null,
            example: null,
          ),
        ],
      ),
    );
  });

  test('parseArbFile collects all keys as rawKeys', () {
    final tester = AppTester.create();
    tester.populateFileSystem({
      'strings_en.arb': '''
{
  "key": "value",
  "key": "duplicated key",
  "key2": "value"
}
''',
    });

    final arbFile = ArbFile(
      filepath: 'strings_en.arb',
      filenameLocale: 'en',
      isMainFile: true,
    );
    final parsedArbFile = parseArbFile(arbFile);
    expect(parsedArbFile.keys, ['key', 'key2']);
    expect(parsedArbFile.rawKeys, ['key', 'key', 'key2']);
  });

  test('Can parse one ignored rule', () {
    final tester = AppTester.create();
    tester.populateFileSystem({
      'intl_en.arb': '''
{
  "snake_case": "value",
  "@snake_case": {
    "@@x-ignore": "naming_convention"
  }
}
''',
    });

    final arbFile = ArbFile(
      filepath: 'intl_en.arb',
      filenameLocale: 'en',
      isMainFile: true,
    );
    final parsedArbFile = parseArbFile(arbFile);
    expect(parsedArbFile.rawKeys, ['snake_case', '@snake_case']);
    expect(parsedArbFile.content['@snake_case'], isA<AtKeyMeta>());
    final meta = parsedArbFile.content['@snake_case'] as AtKeyMeta;
    expect(meta.ignoredRulesRaw, ['naming_convention']);
    expect(meta.ignoredRules, [RuleKey.namingConvention]);
  });

  test('Can parse list of ignored rules', () {
    final tester = AppTester.create();
    tester.populateFileSystem({
      'intl_en.arb': '''
{
  "snake_case": "VALUE",
  "@snake_case": {
    "@@x-ignore": ["naming_convention", "all_caps"]
  }
}
''',
    });

    final arbFile = ArbFile(
      filepath: 'intl_en.arb',
      filenameLocale: 'en',
      isMainFile: true,
    );
    final parsedArbFile = parseArbFile(arbFile);
    expect(parsedArbFile.rawKeys, ['snake_case', '@snake_case']);
    expect(parsedArbFile.content['@snake_case'], isA<AtKeyMeta>());
    final meta = parsedArbFile.content['@snake_case'] as AtKeyMeta;
    expect(meta.ignoredRulesRaw, ['naming_convention', 'all_caps']);
    expect(meta.ignoredRules, [RuleKey.namingConvention, RuleKey.allCaps]);
  });
}
