import 'package:rebellion/src/utils/diff_utils.dart';
import 'package:rebellion/src/utils/exit_exception.dart';
import 'package:test/test.dart';

import '../../infrastructure/app_tester.dart';
import '../../infrastructure/logger.dart';
import '../../infrastructure/test_arb_files.dart';

void main() {
  test('getMissingTranslations stops execution when no main locale found', () {
    AppTester.create();
    expect(
      () => getMissingTranslations(
        [
          createFile(
            isMainFile: false,
            locale: 'en',
            values: {'key1': 'value1'},
          ),
          createFile(
            isMainFile: false,
            locale: 'es',
            values: {'key1': 'value1'},
          ),
        ],
      ),
      throwsA(isA<ExitException>()),
    );
    expect(inMemoryLogger.output, 'No main file found');
  });

  test('getMissingTranslations produces lists of diff files', () {
    AppTester.create();
    final en = createFile(
      isMainFile: true,
      locale: 'en',
      values: {
        'key1': 'value1',
        'key2': 'value2',
      },
    );
    final es = createFile(
      isMainFile: false,
      locale: 'es',
      values: {'key1': 'value1'},
    );
    final diffFiles = getMissingTranslations([en, es]);
    expect(diffFiles.length, 1);
    expect(diffFiles.first.sourceFile, es);
    expect(diffFiles.first.untranslatedKeys, ['key2']);
  });
}
