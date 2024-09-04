import 'package:rebellion/command_runner.dart';
import 'package:rebellion/utils/exit_exception.dart';
import 'package:test/test.dart';

import '../infrastructure/app_tester.dart';
import '../infrastructure/logger.dart';

void main() {
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
}
