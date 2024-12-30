import 'package:rebellion/src/analyze/analyzer_options.dart';
import 'package:rebellion/src/analyze/rules/unused_at_key.dart';
import 'package:rebellion/src/utils/rebellion_options.dart';
import 'package:test/test.dart';

import '../../../infrastructure/app_tester.dart';
import '../../../infrastructure/logger.dart';
import '../../../infrastructure/test_arb_files.dart';

void main() {
  test('UnusedAtKey checks that @-keys have corresponding keys', () async {
    AppTester.create();

    final analyzerOptions = AnalyzerOptions(
      rebellionOptions: RebellionOptions.empty(),
      isSingleFile: true,
      containsMainFile: true,
    );

    // No unused @-keys
    var issues = UnusedAtKey().run(
      [
        createFile(
          values: {
            'key': 'value',
            '@key': 'value',
          },
        )
      ],
      analyzerOptions,
    );
    expect(issues, 0);
    expect(inMemoryLogger.output, isEmpty);

    // Two unused @-keys
    issues = UnusedAtKey().run(
      [
        createFile(
          values: {
            'key': 'value',
            '@key': 'value',
            '@key2': 'value',
            '@key3': 'value',
          },
        )
      ],
      analyzerOptions,
    );
    expect(issues, 2);
    expect(
        inMemoryLogger.output,
        '''
filepath: @-key "@key2" without corresponding key "key2"
filepath: @-key "@key3" without corresponding key "key3"
'''
            .trim());
  });
}
