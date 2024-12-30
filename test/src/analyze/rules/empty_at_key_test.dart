import 'package:rebellion/src/analyze/analyzer_options.dart';
import 'package:rebellion/src/analyze/rules/empty_at_key.dart';
import 'package:rebellion/src/utils/arb_parser/at_key_meta.dart';
import 'package:rebellion/src/utils/rebellion_options.dart';
import 'package:test/test.dart';

import '../../../infrastructure/app_tester.dart';
import '../../../infrastructure/logger.dart';
import '../../../infrastructure/test_arb_files.dart';

void main() {
  test('EmptyAtKeys checks @-keys without description', () async {
    AppTester.create();

    final analyzerOptions = AnalyzerOptions(
      rebellionOptions: RebellionOptions.empty(),
      isSingleFile: true,
      containsMainFile: true,
    );

    // No @-keys - no error
    var issues = EmptyAtKeys().run(
      [
        createFile(values: {'key': 'value'}),
      ],
      analyzerOptions,
    );
    expect(issues, 0);
    expect(inMemoryLogger.output, isEmpty);

    // @-key with description - no error
    inMemoryLogger.clear();
    issues = EmptyAtKeys().run(
      [
        createFile(
          values: {
            'key': 'value',
            '@key': AtKeyMeta(
              description: 'Key description',
              placeholders: [],
            ),
          },
        ),
      ],
      analyzerOptions,
    );
    expect(issues, 0);
    expect(inMemoryLogger.output, isEmpty);

    // No description, no placeholders - error
    inMemoryLogger.clear();
    issues = EmptyAtKeys().run(
      [
        createFile(
          values: {
            'key': 'value',
            '@key': AtKeyMeta(
              description: null,
              placeholders: [],
            ),
          },
        ),
      ],
      analyzerOptions,
    );
    expect(issues, 1);
    expect(
      inMemoryLogger.output,
      'filepath: empty @-key "@key"',
    );

    // Empty description, no placeholders - error
    inMemoryLogger.clear();
    issues = EmptyAtKeys().run(
      [
        createFile(
          values: {
            'key': 'value',
            '@key': AtKeyMeta(
              description: '',
              placeholders: [],
            ),
          },
        ),
      ],
      analyzerOptions,
    );
    expect(issues, 1);
    expect(
      inMemoryLogger.output,
      'filepath: empty @-key "@key"',
    );

    // No description but placeholders - no error
    inMemoryLogger.clear();
    issues = EmptyAtKeys().run(
      [
        createFile(
          values: {
            'key': 'Issues: {count}',
            '@key': AtKeyMeta(
              description: null,
              placeholders: [
                AtKeyPlaceholder(
                  name: 'count',
                  type: null,
                  example: null,
                ),
              ],
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
