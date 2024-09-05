import 'package:rebellion/analyze/checks/missing_plurals.dart';
import 'package:rebellion/utils/file_utils.dart';
import 'package:test/test.dart';

import '../../infrastructure/app_tester.dart';
import '../../infrastructure/logger.dart';
import '../../infrastructure/test_arb_files.dart';

void main() {
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
      RebellionOptions.empty(),
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
      RebellionOptions.empty(),
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
        RebellionOptions.empty(),
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
      RebellionOptions.empty(),
    );
    expect(issues, 3);
    expect(
        inMemoryLogger.output,
        '''
strings_en.arb key key: missing plural values: other
strings_ru.arb key key: missing plural values: other
strings_cy.arb key key: missing plural values: one, two
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
      RebellionOptions.empty(),
    );
    expect(issues, 3);
    expect(
        inMemoryLogger.output,
        '''
strings_en.arb key key: redundant plural values: two
strings_zh.arb key key: redundant plural values: one
strings_ru.arb key key: redundant plural values: two
'''
            .trim());
  });
}
