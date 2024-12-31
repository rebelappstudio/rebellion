import 'package:rebellion/src/analyze/analyzer_options.dart';
import 'package:rebellion/src/analyze/rules/locale_definition_presence.dart';
import 'package:rebellion/src/utils/rebellion_options.dart';
import 'package:test/test.dart';

import '../../../infrastructure/app_tester.dart';
import '../../../infrastructure/logger.dart';
import '../../../infrastructure/test_arb_files.dart';

void main() {
  test('LocaleDefinitionPresent checks that @@locale is present', () async {
    AppTester.create();

    final analyzerOptions = AnalyzerOptions(
      rebellionOptions: RebellionOptions.empty(),
      isSingleFile: true,
      containsMainFile: true,
    );

    // No error when @@locale is present
    var issues = LocaleDefinitionPresence().run(
      [
        createFile(
          values: {
            '@@locale': 'en',
            'key': 'value',
          },
        ),
      ],
      analyzerOptions,
    );
    expect(issues, 0);
    expect(inMemoryLogger.output, isEmpty);

    // Error when @@locale is missing
    inMemoryLogger.clear();
    issues = LocaleDefinitionPresence().run(
      [
        createFile(
          values: {
            'key': 'value',
          },
        ),
      ],
      analyzerOptions,
    );
    expect(issues, 1);
    expect(inMemoryLogger.output, 'filepath: no @@locale key found');
  });
}
