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

  test('Alphabetical sort places message key before its @-key', () async {
    final tester = AppTester.create();
    tester.populateFileSystem({
      'intl_en.arb': '''
{
  "bbb": "value",
  "@aaa": "meta",
  "aaa": "value"
}''',
    });

    await commandRunner.run(['sort', '.', '--sorting', 'alphabetical']);

    expect(
      tester.getFileContent('intl_en.arb'),
      '''
{
  "aaa": "value",
  "@aaa": "meta",
  "bbb": "value"
}'''
          .trim(),
    );
  });

  test('Alphabetical sort pins @@ attributes at the top', () async {
    final tester = AppTester.create();
    tester.populateFileSystem({
      'intl_en.arb': '''
{
  "bbb": "value",
  "@@last_modified": "2020-01-01",
  "aaa": "value",
  "@@locale": "en"
}''',
    });

    await commandRunner.run(['sort', '.', '--sorting', 'alphabetical']);

    expect(
      tester.getFileContent('intl_en.arb'),
      '''
{
  "@@last_modified": "2020-01-01",
  "@@locale": "en",
  "aaa": "value",
  "bbb": "value"
}'''
          .trim(),
    );
  });

  test('Reverse alphabetical sort keeps @@ attributes at the top', () async {
    final tester = AppTester.create();
    tester.populateFileSystem({
      'intl_en.arb': '''
{
  "bbb": "value",
  "@@locale": "en",
  "aaa": "value"
}''',
    });

    await commandRunner.run(['sort', '.', '--sorting', 'alphabetical-reverse']);

    expect(
      tester.getFileContent('intl_en.arb'),
      '''
{
  "@@locale": "en",
  "bbb": "value",
  "aaa": "value"
}'''
          .trim(),
    );
  });

  test('Can sort in reverse alphabetical order', () async {
    final tester = AppTester.create();
    tester.populateFileSystem(testFiles);

    await commandRunner.run(['sort', '.', '--sorting', 'alphabetical-reverse']);
    expect(inMemoryLogger.output, isEmpty);

    expect(
      tester.getFileContent('intl_en.arb'),
      '''
{
  "ccc": "value",
  "@ccc": "value",
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
          .trim(),
    );

    expect(
      tester.getFileContent('intl_es.arb'),
      '''
{
  "aaa": "value",
  "bbb": "value"
}
'''
          .trim(),
    );

    expect(
      tester.getFileContent('intl_fr.arb'),
      '''
{
  "aaa": "value",
  "ccc": "value",
  "bbb": "value"
}
'''
          .trim(),
    );
  });

  test('Follow-main-file leaves main unchanged and mirrors its key order', () async {
    final tester = AppTester.create();
    tester.populateFileSystem({
      'intl_en.arb': '''
{
  "zzz": "value",
  "@aaa": "meta",
  "aaa": "value",
  "@@locale": "en"
}''',
      'intl_es.arb': '''
{
  "extra_b": "x",
  "aaa": "valor",
  "zzz": "valor",
  "@@locale": "es",
  "extra_a": "y"
}''',
    });

    await commandRunner.run(['sort', '.', '--sorting', 'follow-main-file']);

    // Main file order is preserved as-is (including @ before key and @@ at end).
    expect(
      tester.getFileContent('intl_en.arb'),
      '''
{
  "zzz": "value",
  "@aaa": "meta",
  "aaa": "value",
  "@@locale": "en"
}'''
          .trim(),
    );

    // Translation follows main key sequence; extras keep original relative order.
    expect(
      tester.getFileContent('intl_es.arb'),
      '''
{
  "zzz": "valor",
  "aaa": "valor",
  "@@locale": "es",
  "extra_b": "x",
  "extra_a": "y"
}'''
          .trim(),
    );
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
