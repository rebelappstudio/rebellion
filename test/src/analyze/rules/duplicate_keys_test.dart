import 'package:rebellion/src/analyze/analyzer_options.dart';
import 'package:rebellion/src/analyze/rules/duplicate_keys.dart';
import 'package:rebellion/src/utils/arb_parser/arb_file.dart';
import 'package:rebellion/src/utils/arb_parser/parsed_arb_file.dart';
import 'package:rebellion/src/utils/rebellion_options.dart';
import 'package:test/test.dart';

import '../../../infrastructure/app_tester.dart';
import '../../../infrastructure/logger.dart';

void main() {
  test('DuplicatedKeys checks for key duplicates', () {
    AppTester.create();

    final analyzerOptions = AnalyzerOptions(
      rebellionOptions: RebellionOptions.empty(),
      isSingleFile: true,
      containsMainFile: true,
    );

    // No duplicates
    var issues = DuplicatedKeys().run(
      [
        ParsedArbFile(
          file: ArbFile(
            filepath: 'filepath',
            filenameLocale: 'en',
            isMainFile: true,
          ),
          content: {
            'key': 'value',
            '@key': 'value',
          },
          rawKeys: ['key', '@key'],
        )
      ],
      analyzerOptions,
    );
    expect(issues, 0);
    expect(inMemoryLogger.output, isEmpty);

    // Duplicated keys found
    inMemoryLogger.clear();
    issues = DuplicatedKeys().run(
      [
        ParsedArbFile(
          file: ArbFile(
            filepath: 'filepath',
            filenameLocale: 'en',
            isMainFile: true,
          ),
          content: {
            'key': 'value',
            '@key': 'value',
            'key2': 'value2',
          },
          rawKeys: ['key', 'key2', '@key', 'key', '@key'],
        )
      ],
      analyzerOptions,
    );
    expect(issues, 2);
    expect(
      inMemoryLogger.output,
      '''
filepath: file has duplicate key "key"
filepath: file has duplicate key "@key"
'''
          .trim(),
    );
  });
}
