import 'package:rebellion/src/utils/command_runner.dart';
import 'package:rebellion/src/utils/exit_exception.dart';
import 'package:test/test.dart';

import '../../../infrastructure/app_tester.dart';
import '../../../infrastructure/logger.dart';

void main() {
  test('Filename locale is checked against the allowlist', () async {
    final tester = AppTester.create();
    tester.populateFileSystem({
      'intl_xx.arb': '''
{
  "key": "value"
}
''',
    });
    expect(
      () async => await commandRunner.run(['analyze', '.', '--main-locale=xx']),
      throwsA(isA<ExitException>()),
    );
    expect(
        inMemoryLogger.output,
        '''
./intl_xx.arb: no @@locale key found
./intl_xx.arb: filename locale "xx" is not in the allowlist

2 issues found'''
            .trim());
  });

  test('ARB file @@locale is checked agains the allowlist', () {
    final tester = AppTester.create();
    tester.populateFileSystem({
      'intl_en.arb': '''
{
  "@@locale": "xx"
}
'''
    });

    expect(
      () async => await commandRunner.run(['analyze', '.']),
      throwsA(isA<ExitException>()),
    );
    expect(
        inMemoryLogger.output,
        '''
./intl_en.arb: @@locale value "xx" is not in the allowlist
./intl_en.arb: filename locale "en" does not match @@locale value "xx"

2 issues found'''
            .trim());
  });
}
