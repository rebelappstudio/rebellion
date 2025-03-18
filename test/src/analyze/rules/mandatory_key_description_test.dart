import 'package:rebellion/src/analyze/analyzer_options.dart';
import 'package:rebellion/src/analyze/rules/mandatory_key_description.dart';
import 'package:rebellion/src/utils/arb_parser/arb_file.dart';
import 'package:rebellion/src/utils/arb_parser/at_key_meta.dart';
import 'package:rebellion/src/utils/arb_parser/parsed_arb_file.dart';
import 'package:rebellion/src/utils/rebellion_options.dart';
import 'package:test/test.dart';

import '../../../infrastructure/app_tester.dart';
import '../../../infrastructure/logger.dart';
import '../../../infrastructure/test_arb_files.dart';

void main() {
  final analyzerOptions = AnalyzerOptions(
    rebellionOptions: RebellionOptions.empty(),
    isSingleFile: true,
    containsMainFile: true,
  );

  setUp(() {
    inMemoryLogger.clear();
  });

  test('MandatoryKeyDescription checks that key description is present', () {
    AppTester.create();

    // Key description is present
    var issues = MandatoryKeyDescription().run(
      [
        ParsedArbFile(
          file: ArbFile(
            filepath: 'filepath',
            filenameLocale: 'en',
            isMainFile: true,
          ),
          content: {
            'key': 'value',
            '@key': AtKeyMeta(
              description: 'Key description',
              placeholders: [],
              ignoredRulesRaw: [],
            ),
          },
          rawKeys: ['key', '@key'],
        )
      ],
      analyzerOptions,
    );
    expect(issues, 0);
    expect(inMemoryLogger.output, isEmpty);

    // No key description
    inMemoryLogger.clear();
    issues = MandatoryKeyDescription().run(
      [
        ParsedArbFile(
          file: ArbFile(
            filepath: 'filepath',
            filenameLocale: 'en',
            isMainFile: true,
          ),
          content: {
            'key': 'value',
            '@key': AtKeyMeta(
              description: null,
              placeholders: [],
              ignoredRulesRaw: [],
            ),
          },
          rawKeys: ['key', '@key'],
        )
      ],
      analyzerOptions,
    );
    expect(issues, 1);
    expect(
      inMemoryLogger.output,
      'filepath: @-key "@key" must have a description',
    );
  });

  test('Rule can be ignored', () {
    var issues = MandatoryKeyDescription().run(
      [
        createFile(
          values: {
            'key': 'Abc',
            '@key': AtKeyMeta(
              description: null,
              placeholders: [],
              ignoredRulesRaw: ['mandatory_at_key_description'],
            ),
          },
        ),
      ],
      analyzerOptions,
    );
    expect(issues, 0);
    expect(inMemoryLogger.output, isEmpty);
  });
}
