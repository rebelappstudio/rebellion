import 'package:rebellion/src/utils/args.dart';
import 'package:rebellion/src/utils/command_runner.dart';
import 'package:rebellion/src/utils/exit_exception.dart';
import 'package:test/test.dart';

import '../../infrastructure/app_tester.dart';
import '../../infrastructure/logger.dart';

void main() {
  setUp(() {
    inMemoryLogger.clear();
  });

  test('Prints a message when no files and folders specified', () async {
    AppTester.create();

    expect(
      () async => await commandRunner.run(['analyze']),
      throwsA(isA<ExitException>()),
    );

    expect(inMemoryLogger.output, 'No files or folders to analyze');
  });

  test('Prints a message when no issues found', () async {
    final tester = AppTester.create();
    tester.populateFileSystem({
      'strings_en.arb': '''
{
  "@@locale": "en"
}
''',
    });

    await commandRunner.run(['analyze', '.']);
    expect(inMemoryLogger.output, 'No issues found');
  });

  test('Analyze prints number of found issues', () async {
    final tester = AppTester.create();
    tester.populateFileSystem({
      'strings_en.arb': '''
{
  "appTitle": "Rebellion",
  "appTitle": "Rebellion"
}
''',
    });

    expect(
      () async => await commandRunner.run(['analyze', '.']),
      throwsA(isA<ExitException>()),
    );

    expect(
      inMemoryLogger.output,
      '''
./strings_en.arb: file has duplicate key "appTitle"
./strings_en.arb: no @@locale key found

2 issues found'''
          .trim(),
    );
  });

  test('Warning when no main file', () async {
    final tester = AppTester.create();
    tester.populateFileSystem({
      'strings_fi.arb': '{ "appTitle": "Rebeleijona" }',
    });
    expect(
      () async => await commandRunner.run(['analyze', '.']),
      throwsA(isA<ExitException>()),
    );
    // Special message when analyzing one file
    expect(
      inMemoryLogger.output,
      '''
⚠️ Looks like a single file is being analyzed but it's not marked as the main file. Some checks may not work. Use the `main-locale` option to specify the main locale
./strings_fi.arb: no @@locale key found

1 issue found
'''
          .trim(),
    );

    // Analyze multiple files
    inMemoryLogger.clear();
    tester.populateFileSystem({
      'strings_fi.arb': '{ "appTitle": "Rebeleijona" }',
      'strings_fr.arb': '{ "appTitle": "Rebellion" }',
    });
    expect(
      () async => await commandRunner.run(['analyze', '.']),
      throwsA(isA<ExitException>()),
    );
    expect(
      inMemoryLogger.output,
      '''
⚠️ No main file found, some checks may not work. Use the `main-locale` option to specify the main locale
./strings_fi.arb: no @@locale key found
./strings_fr.arb: no @@locale key found

2 issues found
'''
          .trim(),
    );
  });

  test('Console value is preferred over YAML config', () {
    final tester = AppTester.create();
    tester.populateFileSystem({
      'strings_fi.arb': '{}',
      'strings_sv.arb': '{}',
    });
    expect(defaultMainLocale, 'en');
    expect(
      () async => await commandRunner.run(['analyze', '.', '--main-locale=fi']),
      throwsA(isA<ExitException>()),
    );
    expect(
        inMemoryLogger.output,
        // Has no warning about main file
        '''
./strings_fi.arb: no @@locale key found
./strings_sv.arb: no @@locale key found

2 issues found
'''
            .trim());
  });
}
