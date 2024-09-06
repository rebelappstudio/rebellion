import 'package:rebellion/src/analyze/checks/redundant_translations.dart';
import 'package:rebellion/src/utils/rebellion_options.dart';
import 'package:test/test.dart';

import '../../infrastructure/app_tester.dart';
import '../../infrastructure/logger.dart';
import '../../infrastructure/test_arb_files.dart';

void main() {
  setUp(() {
    AppTester.create();
  });

  test(
      'RedundantTranslations reports not issue when there are no redundant translations',
      () {
    final issues = RedundantTranslations().run(
      [
        createFile(
          filepath: 'strings_en.arb',
          locale: 'en',
          isMainFile: true,
          values: {
            'key1': 'value',
            'key2': 'value',
            'key3': 'value',
          },
        ),
        createFile(
          filepath: 'strings_es.arb',
          locale: 'es',
          isMainFile: false,
          values: {
            'key1': 'valor',
            'key2': 'valor',
            'key3': 'valor',
          },
        ),
      ],
      RebellionOptions.empty(),
    );
    expect(issues, isZero);
    expect(inMemoryLogger.output, isEmpty);
  });

  test('RedundantTranslations lists all redundant translations', () {
    final issues = RedundantTranslations().run(
      [
        createFile(
          filepath: 'strings_en.arb',
          locale: 'en',
          isMainFile: true,
          values: {
            'key1': 'value',
            'key2': 'value',
            'key3': 'value',
          },
        ),
        createFile(
          filepath: 'strings_es.arb',
          locale: 'es',
          isMainFile: false,
          values: {
            'key1': 'valor',
            'key2': 'valor',
            'key3': 'valor',
            'key4': 'valor',
            'key5': 'valor',
          },
        ),
      ],
      RebellionOptions.empty(),
    );
    expect(issues, 2);
    expect(
        inMemoryLogger.output,
        '''
strings_es.arb: redundant translation "key4"
strings_es.arb: redundant translation "key5"
'''
            .trim());
  });
}
