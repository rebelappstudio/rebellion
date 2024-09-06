import 'package:rebellion/src/analyze/checks/redundant_at_key.dart';
import 'package:rebellion/src/utils/rebellion_options.dart';
import 'package:test/test.dart';

import '../../infrastructure/app_tester.dart';
import '../../infrastructure/logger.dart';
import '../../infrastructure/test_arb_files.dart';

void main() {
  test('RedundantAtKey checks that @-keys are only present in the main file',
      () {
    AppTester.create();

    var issues = RedundantAtKey().run(
      [
        createFile(
          filepath: 'strings_en.arb',
          locale: 'en',
          isMainFile: true,
          values: {
            'key': 'value',
            '@key': 'value',
          },
        ),
        createFile(
          filepath: 'strings_es.arb',
          locale: 'es',
          isMainFile: false,
          values: {
            'key': 'valor',
          },
        ),
      ],
      RebellionOptions.empty(),
    );
    expect(issues, 0);
    expect(inMemoryLogger.output, isEmpty);

    issues = RedundantAtKey().run(
      [
        createFile(
          filepath: 'strings_en.arb',
          locale: 'en',
          isMainFile: true,
          values: {
            'key': 'value',
            '@key': 'value',
          },
        ),
        createFile(
          filepath: 'strings_es.arb',
          locale: 'es',
          isMainFile: false,
          values: {
            'key': 'valor',
            '@key': 'valor',
          },
        ),
      ],
      RebellionOptions.empty(),
    );
    expect(issues, 1);
    expect(
      inMemoryLogger.output,
      'strings_es.arb: @-key "@key" should only be present in the main file',
    );
  });
}
