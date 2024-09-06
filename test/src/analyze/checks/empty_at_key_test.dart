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

    // No @-keys - no error
    var issues = EmptyAtKeys().run(
      [
        createFile(values: {'key': 'value'}),
      ],
      RebellionOptions.empty(),
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
      RebellionOptions.empty(),
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
      RebellionOptions.empty(),
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
      RebellionOptions.empty(),
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
      RebellionOptions.empty(),
    );
    expect(issues, 0);
    expect(inMemoryLogger.output, isEmpty);
  });
}
