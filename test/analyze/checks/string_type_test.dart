import 'package:rebellion/src/analyze/rules/string_type.dart';
import 'package:rebellion/src/utils/rebellion_options.dart';
import 'package:test/test.dart';

import '../../infrastructure/app_tester.dart';
import '../../infrastructure/logger.dart';
import '../../infrastructure/test_arb_files.dart';

void main() {
  test('StringType checks that all keys are strings', () async {
    AppTester.create();

    var issues = StringType().run(
      [
        createFile(
          values: {
            'key': 'value',
            'key2': 'value2',
          },
        ),
      ],
      RebellionOptions.empty(),
    );
    expect(issues, 0);
    expect(inMemoryLogger.output, isEmpty);

    issues = StringType().run(
      [
        createFile(
          values: {
            'key1': 'value',
            'key2': 1,
            'key3': null,
            'key4': [],
            'key5': {},
            '@key6': 'at-key',
          },
        ),
      ],
      RebellionOptions.empty(),
    );
    expect(issues, 4);
    expect(
        inMemoryLogger.output,
        '''
filepath: "key2" must be a string. Instead "int" was found
filepath: "key3" must be a string. Instead "Null" was found
filepath: "key4" must be a string. Instead "List<dynamic>" was found
filepath: "key5" must be a string. Instead "_Map<dynamic, dynamic>" was found
'''
            .trim());
  });
}
