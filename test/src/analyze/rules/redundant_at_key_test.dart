import 'package:rebellion/src/analyze/analyzer_options.dart';
import 'package:rebellion/src/analyze/rules/redundant_at_key.dart';
import 'package:rebellion/src/utils/arb_parser/at_key_meta.dart';
import 'package:rebellion/src/utils/rebellion_options.dart';
import 'package:test/test.dart';

import '../../../infrastructure/app_tester.dart';
import '../../../infrastructure/logger.dart';
import '../../../infrastructure/test_arb_files.dart';

void main() {
  final analyzerOptions = AnalyzerOptions(
    rebellionOptions: RebellionOptions.empty(),
    isSingleFile: false,
    containsMainFile: true,
  );

  setUp(() {
    AppTester.create();
  });

  test('RedundantAtKey checks that @-keys are only present in the main file',
      () {
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
      analyzerOptions,
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
      analyzerOptions,
    );
    expect(issues, 1);
    expect(
      inMemoryLogger.output,
      'strings_es.arb: @-key "@key" should only be present in the main file',
    );
  });

  test('Rule can be ignored', () {
    final issues = RedundantAtKey().run(
      [
        createFile(
          filepath: 'strings_en.arb',
          locale: 'en',
          isMainFile: true,
          values: {
            'key': 'value',
            '@key': AtKeyMeta(
              description: 'description',
              placeholders: [],
              ignoredRulesRaw: [],
            ),
          },
        ),
        createFile(
          filepath: 'strings_es.arb',
          locale: 'es',
          isMainFile: false,
          values: {
            'key': 'valor',
            '@key': AtKeyMeta(
              description: 'description',
              placeholders: [],
              ignoredRulesRaw: ['redundant_at_key'],
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
