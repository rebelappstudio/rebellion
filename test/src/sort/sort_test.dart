import 'package:rebellion/src/utils/command_runner.dart';
import 'package:test/test.dart';

import '../../infrastructure/app_tester.dart';
import '../../infrastructure/logger.dart';

void main() {
  test('Can sort alphabetically', () async {
    final tester = AppTester.create();
    tester.populateFileSystem(testFiles);

    await commandRunner.run(['sort', '.', '--sorting', 'alphabetical']);
    expect(inMemoryLogger.output, isEmpty);

    expect(
      tester.getFileContent('intl_en.arb'),
      '''
{
  "aaa": "value",
  "bbb": "value",
  "ccc": "value",
  "@ccc": "value"
}'''
          .trim(),
    );

    expect(
      tester.getFileContent('intl_es.arb'),
      '''
{
  "aaa": "value",
  "bbb": "value"
}'''
          .trim(),
    );

    expect(
      tester.getFileContent('intl_fr.arb'),
      '''
{
  "aaa": "value",
  "bbb": "value",
  "ccc": "value"
}'''
          .trim(),
    );
  });

  test('Can sort in reverse alphabetical order', () async {
    final tester = AppTester.create();
    tester.populateFileSystem(testFiles);

    await commandRunner.run(
      ['sort', '.', '--sorting', 'alphabetical-reverse'],
    );
    expect(inMemoryLogger.output, isEmpty);

    expect(
      tester.getFileContent('intl_en.arb'),
      '''
{
  "@ccc": "value",
  "ccc": "value",
  "bbb": "value",
  "aaa": "value"
}
'''
          .trim(),
    );

    expect(
      tester.getFileContent('intl_es.arb'),
      '''
{
  "bbb": "value",
  "aaa": "value"
}
'''
          .trim(),
    );

    expect(
      tester.getFileContent('intl_fr.arb'),
      '''
{
  "ccc": "value",
  "bbb": "value",
  "aaa": "value"
}
'''
          .trim(),
    );
  });

  test("Can sort following main locale's file", () {
    final tester = AppTester.create();
    tester.populateFileSystem(testFiles);

    commandRunner.run(['sort', '.', '--sorting', 'follow-main-file']);
    expect(inMemoryLogger.output, isEmpty);

    expect(
        tester.getFileContent('intl_en.arb'),
        '''
{
  "aaa": "value",
  "ccc": "value",
  "@ccc": "value",
  "bbb": "value"
}
'''
            .trim());

    expect(
        tester.getFileContent('intl_es.arb'),
        '''
{
  "aaa": "value",
  "bbb": "value"
}
'''
            .trim());

    expect(
        tester.getFileContent('intl_fr.arb'),
        '''
{
  "aaa": "value",
  "ccc": "value",
  "bbb": "value"
}
'''
            .trim());
  });
}

const testFiles = {
  'intl_en.arb': '''
{
  "aaa": "value",
  "ccc": "value",
  "@ccc": "value",
  "bbb": "value"
}''',
  'intl_es.arb': '''
{
  "aaa": "value",
  "bbb": "value"
}''',
  'intl_fr.arb': '''
{
  "bbb": "value",
  "ccc": "value",
  "aaa": "value"
}''',
};
