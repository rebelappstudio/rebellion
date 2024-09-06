import 'package:rebellion/src/analyze/rules/missing_translations.dart';
import 'package:rebellion/src/utils/rebellion_options.dart';
import 'package:test/test.dart';

import '../../../infrastructure/app_tester.dart';
import '../../../infrastructure/logger.dart';
import '../../../infrastructure/test_arb_files.dart';

void main() {
  test('MissingTranslations lists all missing translations', () async {
    AppTester.create();

    var issues = MissingTranslations().run(
      [
        createFile(
          filepath: 'strings_en.arb',
          locale: 'en',
          isMainFile: true,
          values: {
            'key1': 'value1',
          },
        ),
        createFile(
          filepath: 'strings_es.arb',
          locale: 'es',
          isMainFile: false,
          values: {
            'key1': 'valor',
          },
        ),
      ],
      RebellionOptions.empty(),
    );
    expect(issues, 0);
    expect(inMemoryLogger.output, isEmpty);

    issues = MissingTranslations().run(
      [
        createFile(
          filepath: 'strings_en.arb',
          locale: 'en',
          isMainFile: true,
          values: {
            'key1': 'value1',
            'key2': 'value2',
            'key3': 'value3',
          },
        ),
        createFile(
          filepath: 'strings_es.arb',
          locale: 'es',
          isMainFile: false,
          values: {
            'key1': 'valor',
          },
        ),
      ],
      RebellionOptions.empty(),
    );
    expect(issues, 1);
    expect(
      inMemoryLogger.output,
      'strings_es.arb: missing translations "key2", "key3"',
    );
  });
}
