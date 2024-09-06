import 'package:rebellion/src/analyze/checks/at_key_type.dart';
import 'package:rebellion/src/utils/arb_parser/at_key_meta.dart';
import 'package:rebellion/src/utils/rebellion_options.dart';
import 'package:test/test.dart';

import '../../infrastructure/app_tester.dart';
import '../../infrastructure/logger.dart';
import '../../infrastructure/test_arb_files.dart';

void main() {
  test('At key check ensures at key type', () {
    AppTester.create();

    // Only at key is checked
    var issues = AtKeyType().run(
      [
        createFile(values: {'key': 'value'}),
      ],
      RebellionOptions.empty(),
    );
    expect(issues, 0);
    expect(inMemoryLogger.output, isEmpty);

    // At key type is incorrect
    issues = AtKeyType().run(
      [
        createFile(values: {
          'key': 'value',
          '@key': 'value',
        }),
      ],
      RebellionOptions.empty(),
    );
    expect(issues, 1);
    expect(
      inMemoryLogger.output,
      'filepath: @-key "@key" must be a JSON object. Instead "String" was found',
    );

    // At key type is correct
    inMemoryLogger.clear();
    issues = AtKeyType().run(
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
  });
}
