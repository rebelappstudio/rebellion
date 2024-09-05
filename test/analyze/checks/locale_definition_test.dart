import 'package:rebellion/analyze/checks/locale_definition.dart';
import 'package:rebellion/utils/file_utils.dart';
import 'package:test/test.dart';

import '../../infrastructure/app_tester.dart';
import '../../infrastructure/logger.dart';
import '../../infrastructure/test_arb_files.dart';

void main() {
  test('LocaleDefinitionPresent checks that @@locale is present', () async {
    AppTester.create();

    // No error when @@locale is present
    var issues = LocaleDefinitionPresent().run(
      [
        createFile(
          values: {
            '@@locale': 'en',
            'key': 'value',
          },
        ),
      ],
      RebellionOptions.empty(),
    );
    expect(issues, 0);
    expect(inMemoryLogger.output, isEmpty);

    // Error when @@locale is missing
    inMemoryLogger.clear();
    issues = LocaleDefinitionPresent().run(
      [
        createFile(
          values: {
            'key': 'value',
          },
        ),
      ],
      RebellionOptions.empty(),
    );
    expect(issues, 1);
    expect(inMemoryLogger.output, 'filepath: no @@locale key found');
  });
}
