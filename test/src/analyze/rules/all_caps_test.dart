import 'package:rebellion/src/analyze/analyzer_options.dart';
import 'package:rebellion/src/analyze/rules/all_caps.dart';
import 'package:rebellion/src/utils/arb_parser/at_key_meta.dart';
import 'package:rebellion/src/utils/rebellion_options.dart';
import 'package:test/test.dart';

import '../../../infrastructure/app_tester.dart';
import '../../../infrastructure/logger.dart';
import '../../../infrastructure/test_arb_files.dart';

void main() {
  late final options = AnalyzerOptions.fromFiles(
    rebellionOptions: RebellionOptions.empty(),
    files: const [],
  );

  setUp(() {
    // Reset logger before each test
    AppTester.create();
  });

  test('AllCaps checks simple strings', () {
    var issues = AllCaps().run(oneKeyFile('String'), options);
    expect(issues, 0);
    expect(inMemoryLogger.output, isEmpty);

    issues = AllCaps().run(oneKeyFile('STRING'), options);
    expect(issues, 1);
    expect(inMemoryLogger.output, 'filepath: all caps string key "key"');
  });

  test('AllCaps checks string with variables', () {
    var issues = AllCaps().run(
      oneKeyFile('Issues: {count}'),
      options,
    );
    expect(issues, 0);
    expect(inMemoryLogger.output, isEmpty);

    issues = AllCaps().run(oneKeyFile('{count} ISSUES'), options);
    expect(issues, 1);
    expect(inMemoryLogger.output, 'filepath: all caps string key "key"');
  });

  test('AllCaps ignores single letter strings with placeholders', () {
    var issues = AllCaps().run(
      oneKeyFile('A {placeholder}'),
      options,
    );
    expect(issues, 0);
    expect(inMemoryLogger.output, isEmpty);
  });

  test('AllCaps checks plurals', () {
    var issues = AllCaps().run(
      oneKeyFile('{count, plural, one {String} two {Strings}}'),
      options,
    );
    expect(issues, 0);
    expect(inMemoryLogger.output, isEmpty);

    issues = AllCaps().run(
      oneKeyFile(
        '{count, plural, zero{NO STRINGS} one{ONE STRING} two{{count} STRING} few{{count} STRING} many{{count} STRING} other{{count} STRINGS}}',
      ),
      options,
    );
    expect(issues, 6);
    expect(
        inMemoryLogger.output,
        '''
filepath key key: all caps string in case "zero"
filepath key key: all caps string in case "one"
filepath key key: all caps string in case "two"
filepath key key: all caps string in case "few"
filepath key key: all caps string in case "many"
filepath key key: all caps string in case "other"
'''
            .trim());
  });

  test('AllCaps checks gender', () {
    var issues = AllCaps().run(
      oneKeyFile('{sex, select, male{His} female{Her} other{Their}}'),
      options,
    );
    expect(issues, 0);
    expect(inMemoryLogger.output, isEmpty);

    issues = AllCaps().run(
      oneKeyFile(
        '{sex, select, male{HIS} female{HER} other{THEIR}}',
      ),
      options,
    );
    expect(issues, 3);
    expect(
      inMemoryLogger.output,
      '''
filepath key key: all caps string in case "female"
filepath key key: all caps string in case "male"
filepath key key: all caps string in case "other"
'''
          .trim(),
    );
  });

  test('AllCaps checks select', () {
    var issues = AllCaps().run(
      oneKeyFile('{color, select, red{Red} blue{Blue} other{Other}}'),
      options,
    );
    expect(issues, 0);
    expect(inMemoryLogger.output, isEmpty);

    issues = AllCaps().run(
      oneKeyFile('{color, select, red{RED} blue{Blue} other{OTHER}}'),
      options,
    );
    expect(issues, 2);
    expect(
      inMemoryLogger.output,
      '''
filepath key key: all caps string in case "red"
filepath key key: all caps string in case "other"
'''
          .trim(),
    );
  });

  test('AllCaps only checks letters', () {
    expect(AllCaps.isAllCapsString(''), isFalse);
    expect(AllCaps.isAllCapsString('ABC'), isTrue);
    expect(AllCaps.isAllCapsString('Abc'), isFalse);
    expect(AllCaps.isAllCapsString('123'), isFalse);
    expect(AllCaps.isAllCapsString('__123-'), isFalse);
    expect(AllCaps.isAllCapsString('AAA12'), isFalse);
    expect(AllCaps.isAllCapsString('A-1'), isFalse);
    expect(AllCaps.isAllCapsString('FOOBAR:'), isFalse);
    expect(AllCaps.isAllCapsString('FÜBÆR'), isTrue);
    expect(AllCaps.isAllCapsString('Fùbæř'), isFalse);
    expect(AllCaps.isAllCapsString('фубар'), isFalse);
    expect(AllCaps.isAllCapsString('ФУБАР'), isTrue);
    expect(AllCaps.isAllCapsString('😉'), isFalse);
    expect(AllCaps.isAllCapsString('☝🏾'), isFalse);

    // Special case for single character strings
    expect(AllCaps.isAllCapsString('A'), isFalse);
    expect(AllCaps.isAllCapsString('a'), isFalse);
    expect(AllCaps.isAllCapsString('A '), isFalse);
  });

  test('Rule can be ignored', () {
    var issues = AllCaps().run(
      [
        createFile(
          values: {
            'key1': 'ABC',
            'key2': 'DEF',
            '@key2': AtKeyMeta(
              description: null,
              placeholders: [],
              ignoredRulesRaw: ['all_caps'],
            ),
          },
        ),
      ],
      options,
    );
    expect(issues, 1);
    expect(
        inMemoryLogger.output,
        '''
filepath: all caps string key "key1"
'''
            .trim());
  });
}
