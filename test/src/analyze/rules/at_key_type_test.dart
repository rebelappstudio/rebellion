import 'package:rebellion/src/analyze/analyzer_options.dart';
import 'package:rebellion/src/analyze/rules/at_key_type.dart';
import 'package:rebellion/src/utils/arb_parser/at_key_meta.dart';
import 'package:rebellion/src/utils/rebellion_options.dart';
import 'package:test/test.dart';

import '../../../infrastructure/app_tester.dart';
import '../../../infrastructure/logger.dart';
import '../../../infrastructure/test_arb_files.dart';

void main() {
  test('At key check ensures at key type', () {
    AppTester.create();

    // Only at key is checked
    final rebellionOptions = RebellionOptions.empty();
    var files = [
      createFile(values: {'key': 'value'}),
    ];
    var issues = AtKeyType().run(
      files,
      AnalyzerOptions.fromFiles(
        rebellionOptions: rebellionOptions,
        files: files,
      ),
    );
    expect(issues, 0);
    expect(inMemoryLogger.output, isEmpty);

    // At key type is incorrect
    files = [
      createFile(values: {
        'key': 'value',
        '@key': 'value',
      }),
    ];
    issues = AtKeyType().run(
      files,
      AnalyzerOptions.fromFiles(
        rebellionOptions: rebellionOptions,
        files: files,
      ),
    );
    expect(issues, 1);
    expect(
      inMemoryLogger.output,
      'filepath: @-key "@key" must be a JSON object. Instead "String" was found',
    );

    // At key type is correct
    inMemoryLogger.clear();
    files = [
      createFile(
        values: {
          'key': 'value',
          '@key': AtKeyMeta(
            description: 'Key description',
            placeholders: [],
          ),
        },
      ),
    ];
    issues = AtKeyType().run(
      files,
      AnalyzerOptions.fromFiles(
        rebellionOptions: rebellionOptions,
        files: files,
      ),
    );
    expect(issues, 0);
    expect(inMemoryLogger.output, isEmpty);
  });
}
