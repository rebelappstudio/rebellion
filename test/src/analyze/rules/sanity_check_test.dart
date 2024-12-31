import 'package:rebellion/src/analyze/analyzer_options.dart';
import 'package:rebellion/src/analyze/rules/rule.dart';
import 'package:rebellion/src/analyze/rules/sanity_check.dart';
import 'package:rebellion/src/utils/arb_parser/at_key_meta.dart';
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
    AppTester.create();
  });

  test("SanityCheck doesn't report known rule names", () {
    final issues = SanityCheck().run(
      [
        createFile(
          values: {
            'key': 'value',
            '@key': AtKeyMeta(
              description: null,
              placeholders: [],
              ignoredRulesRaw: [RuleKey.allCaps.key],
            ),
          },
        ),
      ],
      analyzerOptions,
    );
    expect(issues, isZero);
    expect(inMemoryLogger.output, isEmpty);
  });

  test('SanityCheck reports unknown ignored rules', () {
    final issues = SanityCheck().run(
      [
        createFile(
          values: {
            'key': 'value',
            '@key': AtKeyMeta(
              description: null,
              placeholders: [],
              ignoredRulesRaw: ['something-something'],
            ),
          },
        ),
      ],
      analyzerOptions,
    );

    expect(issues, 1);
    expect(
      inMemoryLogger.output,
      'filepath: key "@key" contains unknown ignored rule: "something-something"',
    );
  });
}
