import 'package:rebellion/src/utils/command_runner.dart';
import 'package:rebellion/src/utils/exit_exception.dart';
import 'package:test/test.dart';

import '../../../infrastructure/app_tester.dart';
import '../../../infrastructure/logger.dart';

void main() {
  test('No error when locales match', () {
    final tester = AppTester.create();
    tester.populateFileSystem({
      'intl_fi.arb': '''
{
  "@@locale": "fi"
}
'''
    });

    commandRunner.run(['analyze', '.', '--main-locale=fi']);
    expect(inMemoryLogger.output, 'No issues found');
  });

  test("Error when filename and content locales don't match", () {
    final tester = AppTester.create();
    tester.populateFileSystem({
      'intl_fi.arb': '''
{
  "@@locale": "en"
}
'''
    });

    expect(
      () => commandRunner.run(['analyze', '.', '--main-locale=fi']),
      throwsA(isA<ExitException>()),
    );
    expect(
        inMemoryLogger.output,
        '''
./intl_fi.arb: filename locale "fi" does not match @@locale value "en"

1 issue found'''
            .trim());
  });
}
