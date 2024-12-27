import 'package:args/args.dart';
import 'package:rebellion/src/analyze/rules/naming_convention.dart';
import 'package:rebellion/src/sort/sort.dart';
import 'package:rebellion/src/utils/args.dart';
import 'package:rebellion/src/utils/rebellion_options.dart';
import 'package:test/test.dart';

import '../../infrastructure/app_tester.dart';

void main() {
  test('Parse main locale from CLI arguments', () {
    final parser = ArgParser()
      ..addOption(CliArgs.mainLocaleParam, defaultsTo: defaultMainLocale);

    var argResults = parser.parse(['--main-locale=en']);
    var options = RebellionOptions.fromCliArguments(argResults);
    expect(options.mainLocale, 'en');

    argResults = parser.parse(['--main-locale=fi']);
    options = RebellionOptions.fromCliArguments(argResults);
    expect(options.mainLocale, 'fi');

    argResults = parser.parse([]);
    options = RebellionOptions.fromCliArguments(argResults);
    expect(options.mainLocale, 'en');
    expect(options.mainLocale, defaultMainLocale);
  });

  test('Uses default options when no yaml file provided', () async {
    final tester = AppTester.create();
    var options = RebellionOptions.loadYaml();
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

    options = RebellionOptions.loadYaml();
    expect(options, isNot(RebellionOptions.empty()));
    expect(options.mainLocale, 'fi');
    expect(options.namingConvention, NamingConvention.snake);
    expect(options.sorting, Sorting.alphabetical);

    tester.setConfigFile('''
rules:
  # - all_caps
  #- string_type
  - at_key_type

options:
  main_locale: fi
  naming_convention: snake
  sorting: follow-main-file
''');
    options = RebellionOptions.loadYaml();
    expect(options.allCapsRuleEnabled, isFalse);
    expect(options.stringTypeRuleEnabled, isFalse);
    expect(options.atKeyTypeRuleEnabled, isTrue);
    expect(options.unusedAtKeyRuleEnabled, isFalse);
    expect(options.missingPluralsRuleEnabled, isFalse);
  });
}