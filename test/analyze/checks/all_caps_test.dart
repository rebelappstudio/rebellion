import 'package:rebellion/analyze/checks/all_caps.dart';
import 'package:rebellion/utils/file_utils.dart';
import 'package:test/test.dart';

import '../../infrastructure/app_tester.dart';
import '../../infrastructure/test_arb_files.dart';
import '../../infrastructure/logger.dart';

void main() {
  late final options = RebellionOptions.empty();

  setUp(() {
    // Reset logger before each test
    AppTester.create();
  });

  test('All caps checks simple strings', () {
    var issues = AllCaps().run(oneKeyFile('String'), options);
    expect(issues, 0);
    expect(inMemoryLogger.output, isEmpty);

    issues = AllCaps().run(oneKeyFile('STRING'), options);
    expect(issues, 1);
    expect(inMemoryLogger.output, 'filepath: all caps string key "key"');
  });

  test('All caps checks string with variables', () {
    var issues = AllCaps().run(
      oneKeyFile('Issues: {count}'),
      options,
    );
    expect(issues, 0);
    expect(inMemoryLogger.output, isEmpty);

    issues = AllCaps().run(oneKeyFile('ISSUES: {count}'), options);
    expect(issues, 1);
    expect(inMemoryLogger.output, 'filepath: all caps string key "key"');
  });

  test('All caps checks plurals', () {
    var issues = AllCaps().run(
      oneKeyFile('{count, plural, one {String} two {Strings}}'),
      options,
    );
    expect(issues, 0);
    expect(inMemoryLogger.output, isEmpty);

    issues = AllCaps().run(
      oneKeyFile(
        '{count, plural, one{STRING} two{{count} String} other{{count} STRINGS}}',
      ),
      options,
    );
    expect(issues, 2);
    expect(
        inMemoryLogger.output,
        '''
filepath key key: all caps string in case "one"
filepath key key: all caps string in case "other"
'''
            .trim());
  });

  test('All caps checks gender', () {
    var issues = AllCaps().run(
      oneKeyFile('{sex, select, male{His} female{Her} other{Their}}'),
      options,
    );
    expect(issues, 0);
    expect(inMemoryLogger.output, isEmpty);

    issues = AllCaps().run(
      oneKeyFile(
        '{sex, select, male{His} female{Her} other{THEIR}}',
      ),
      options,
    );
    expect(issues, 1);
    expect(
      inMemoryLogger.output,
      'filepath key key: all caps string in case "other"',
    );
  });

  test('All caps checks select', () {
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
}
