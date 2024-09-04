import 'package:rebellion/analyze/checks/naming_convention.dart';
import 'package:rebellion/sort/sort.dart';
import 'package:rebellion/utils/file_utils.dart';
import 'package:test/test.dart';

import '../infrastructure/app_tester.dart';

void main() {
  test('Uses default options when no yaml file provided', () async {
    final tester = AppTester.create();
    var options = loadOptionsYaml();
    expect(options, RebellionOptions.empty());

    tester.setConfigFile('''
rules:
  - all_caps
  - string_type
  - at_key_type
  - duplicated_keys
  - empty_at_key
  - locale_definition
  - mandatory_at_key_description
  - missing_placeholders
  - missing_plurals
  - missing_translations
  - naming_convention
  - redundant_at_key
  - redundant_translations
  - unused_at_key

options:
  main_locale: fi
  naming_convention: snake
  sorting: alphabetical

''');

    options = loadOptionsYaml();
    expect(options, isNot(RebellionOptions.empty()));
    expect(options.mainLocale, 'fi');
    expect(options.namingConvention, NamingConvention.snake);
    expect(options.sorting, Sorting.alphabetical);
  });
}
