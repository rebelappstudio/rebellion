import 'package:rebellion/src/analyze/analyzer_options.dart';
import 'package:rebellion/src/analyze/rules/missing_plurals.dart';
import 'package:rebellion/src/utils/arb_parser/at_key_meta.dart';
import 'package:rebellion/src/utils/rebellion_options.dart';
import 'package:test/test.dart';

import '../../../infrastructure/app_tester.dart';
import '../../../infrastructure/logger.dart';
import '../../../infrastructure/test_arb_files.dart';

void main() {
  final analyzerOptions = AnalyzerOptions(
    rebellionOptions: RebellionOptions.empty(),
    isSingleFile: false,
    containsMainFile: true,
  );

  setUp(() {
    AppTester.create();
  });

  test("MissingPlurals reports no issues when there's not missing plurals", () {
    final issues = MissingPlurals().run(
      [
        createFile(
          isMainFile: true,
          locale: 'en',
          values: {
            'key': '{count, plural, one{one day} other{{count} days}}',
          },
        ),
        createFile(
          isMainFile: false,
          locale: 'ru',
          values: {
            'key':
                '{count, plural, one{один день} few{{count} дня} many{{count} дней} other{{count} дней}}',
          },
        ),
        createFile(
          isMainFile: false,
          locale: 'cy',
          values: {
            'key':
                '{count, plural, zero{0 cwn} one{1 ci} two{2 gi} few{{count} chi} many{{count} chi} other{{count} ci}}',
          },
        ),
      ],
      analyzerOptions,
    );
    expect(issues, 0);
    expect(inMemoryLogger.output, isEmpty);
  });

  test("MissingPlurals ignores selects and genders", () {
    final issues = MissingPlurals().run(
      [
        createFile(
          isMainFile: true,
          locale: 'en',
          values: {
            'key1': '{type, select, cat{cat} dog{dog} other{other}}',
            'key2': '{sex, select, male{His} female{Her} other{THEIR}}'
          },
        ),
        createFile(
          isMainFile: false,
          locale: 'fi',
          values: {
            'key1': '{type, select, cat{kissa} dog{koira}}',
            'key2': '{sex, select, male{hänen} female{hänen}'
          },
        ),
      ],
      analyzerOptions,
    );
    expect(issues, 0);
    expect(inMemoryLogger.output, isEmpty);
  });

  test("MissingPlurals throws an exception when locale is unknown", () {
    expect(
      () => MissingPlurals().run(
        [
          createFile(
            isMainFile: true,
            locale: 'non-existing-locale',
            values: {
              'key': '{count, plural, one{one day} other{{count} days}}',
            },
          ),
        ],
        analyzerOptions,
      ),
      throwsA(
        predicate((e) =>
            e is Exception &&
            e.toString().contains(
                'Failed to find plural rules for non-existing-locale')),
      ),
    );
  });

  test("MissingPlurals reports missing plurals for locale", () {
    final issues = MissingPlurals().run(
      [
        createFile(
          filepath: 'strings_en.arb',
          isMainFile: true,
          locale: 'en',
          // Missing 'other'
          values: {'key': '{count, plural, one{one day}}}'},
        ),
        createFile(
          filepath: 'strings_zh.arb',
          isMainFile: false,
          locale: 'zh',
          values: {'key': '{count, plural, other{{count} 天}}'},
        ),
        createFile(
          filepath: 'strings_ru.arb',
          isMainFile: false,
          locale: 'ru',
          values: {
            // Missing 'other'
            'key':
                '{count, plural, one{один день} few{{count} дня} many{{count} дней}}',
          },
        ),
        createFile(
          filepath: 'strings_cy.arb',
          isMainFile: false,
          locale: 'cy',
          values: {
            // Missing 'one' and 'two'
            'key':
                '{count, plural, zero{0 cwn} few{{count} chi} many{{count} chi} other{{count} ci}}',
          },
        ),
      ],
      analyzerOptions,
    );
    expect(issues, 4);
    expect(
        inMemoryLogger.output,
        '''
strings_en.arb key "key" is missing a plural value "other"
strings_ru.arb key "key" is missing a plural value "other"
strings_cy.arb key "key" is missing a plural value "one"
strings_cy.arb key "key" is missing a plural value "two"
'''
            .trim());
  });

  test("MissingPlurals reports redundant plurals for locale", () {
    final issues = MissingPlurals().run(
      [
        createFile(
          filepath: 'strings_en.arb',
          isMainFile: true,
          locale: 'en',
          // Redundant 'two'
          values: {
            'key':
                '{count, plural, one{one day} two{two days} other{{count} days}}'
          },
        ),
        createFile(
          filepath: 'strings_zh.arb',
          isMainFile: false,
          locale: 'zh',
          // Redundant 'one'
          values: {'key': '{count, plural, one{1 天} other{{count} 天}}'},
        ),
        createFile(
          filepath: 'strings_ru.arb',
          isMainFile: false,
          locale: 'ru',
          values: {
            // Redundant 'two'
            'key':
                '{count, plural, one{один день} two{2 дня} few{{count} дня} many{{count} дней} other{{count} other}}',
          },
        ),
      ],
      analyzerOptions,
    );
    expect(issues, 3);
    expect(
        inMemoryLogger.output,
        '''
strings_en.arb key "key" contains a redundant plural value "two"
strings_zh.arb key "key" contains a redundant plural value "one"
strings_ru.arb key "key" contains a redundant plural value "two"
'''
            .trim());
  });

  test('Rule can be ignored', () {
    final issues = MissingPlurals().run(
      [
        createFile(
          filepath: 'strings_en.arb',
          isMainFile: true,
          locale: 'en',
          values: {
            // Missing 'other'
            'key': '{count, plural, one{one day}}}',
            "@key": AtKeyMeta(
              description: null,
              placeholders: [],
              ignoredRulesRaw: ['missing_plurals'],
            ),
          },
        ),
      ],
      analyzerOptions,
    );
    expect(issues, 0);
    expect(inMemoryLogger.output, isEmpty);
  });
}
