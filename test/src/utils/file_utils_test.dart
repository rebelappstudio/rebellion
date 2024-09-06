import 'dart:convert';

import 'package:rebellion/src/analyze/rules/naming_convention.dart';
import 'package:rebellion/src/sort/sort.dart';
import 'package:rebellion/src/utils/file_reader.dart';
import 'package:rebellion/src/utils/file_utils.dart';
import 'package:rebellion/src/utils/rebellion_options.dart';
import 'package:test/test.dart';

import '../../infrastructure/app_tester.dart';

void main() {
  test('getArbFiles returns all available files', () {
    final tester = AppTester.create();
    tester.populateFileSystem({
      'strings_en.arb': '{}',
      'strings_fi.arb': '{}',
      'strings_fi_diff.arb': '{}',
    });

    var files = getArbFiles(['./strings_en.arb'], 'en');
    expect(files.length, 1);
    expect(files.first.isMainFile, isTrue);
    expect(files.first.filepath, './strings_en.arb');
    expect(files.first.locale, 'en');

    files = getArbFiles(['./strings_en.arb', './strings_fi.arb'], 'en');
    expect(files.length, 2);

    // Diffs and other files are ignored
    files = getArbFiles(['.'], 'en');
    expect(files.length, 2);
    expect(files[0].isMainFile, isTrue);
    expect(files[0].locale, 'en');
    expect(files[1].isMainFile, isFalse);
    expect(files[1].locale, 'fi');
  });

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

  test('Writing ARB file writes valid JSON file', () {
    AppTester.create();
    final content = {
      '@@locale': 'en',
      '@key': 'value',
    };
    writeArbFile(content, 'strings_en.arb');

    final files = getArbFiles(['./strings_en.arb'], 'en');
    expect(files.length, equals(1));
    expect(files.first.isMainFile, isTrue);
    expect(files.first.filepath, './strings_en.arb');
    expect(files.first.locale, 'en');

    final readFileContent = fileReader.readFile('./strings_en.arb');
    final readFile = json.decode(readFileContent);
    expect(readFile, content);
  });

  test('getLocaleFromFilepath returns locale from filename', () {
    expect(getLocaleFromFilepath('en.arb'), 'en');
    expect(getLocaleFromFilepath('l10n_en.arb'), 'en');
    expect(getLocaleFromFilepath('intl_en.arb'), 'en');
    expect(getLocaleFromFilepath('app_strings_en.arb'), 'en');
    expect(getLocaleFromFilepath('strings_en.arb'), 'en');
    expect(getLocaleFromFilepath('strings_fi.arb'), 'fi');
    expect(getLocaleFromFilepath('strings_fi_diff.arb'), null);
    expect(getLocaleFromFilepath('strings.yaml'), null);
    expect(getLocaleFromFilepath('strings_en.yaml'), null);
    expect(getLocaleFromFilepath('strings_en_uk.arb'), 'en');
    expect(getLocaleFromFilepath('strings_en_US.arb'), 'en');

    expect(
      () => getLocaleFromFilepath('strings.arb'),
      exceptionWithMessage("Filename can't be parsed"),
    );

    expect(
      () => getLocaleFromFilepath('strings_english.arb'),
      exceptionWithMessage("Filename can't be parsed"),
    );

    expect(
      () => getLocaleFromFilepath('strings_ac.arb'),
      exceptionWithMessage('Locale not supported'),
    );
  });
}

Matcher exceptionWithMessage(String message) {
  return throwsA(
    predicate((e) => e is Exception && e.toString().contains(message)),
  );
}
