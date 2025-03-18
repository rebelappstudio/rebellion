import 'dart:convert';

import 'package:rebellion/src/utils/exit_exception.dart';
import 'package:rebellion/src/utils/file_reader.dart';
import 'package:rebellion/src/utils/file_utils.dart';
import 'package:test/test.dart';

import '../../infrastructure/app_tester.dart';
import '../../infrastructure/logger.dart';

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
    expect(files.first.filenameLocale, 'en');

    files = getArbFiles(['./strings_en.arb', './strings_fi.arb'], 'en');
    expect(files.length, 2);

    // Diffs and other files are ignored
    files = getArbFiles(['.'], 'en');
    expect(files.length, 2);
    expect(files[0].isMainFile, isTrue);
    expect(files[0].filenameLocale, 'en');
    expect(files[1].isMainFile, isFalse);
    expect(files[1].filenameLocale, 'fi');
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
    expect(files.first.filenameLocale, 'en');

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
    expect(getLocaleFromFilepath('strings_en_US.arb'), 'en');
    expect(getLocaleFromFilepath('strings_fil.arb'), 'fil');
    expect(getLocaleFromFilepath('strings_gsw.arb'), 'gsw');

    expect(
      () => getLocaleFromFilepath('strings.arb'),
      exceptionWithMessage("Filename can't be parsed"),
    );

    expect(
      () => getLocaleFromFilepath('strings_english.arb'),
      exceptionWithMessage("Filename can't be parsed"),
    );
  });

  test('ensureFilesAndFoldersExist checks if files and folders exist', () {
    AppTester.create();
    fileReader.directory('dir1').createSync();
    fileReader.file('dir1/file1').createSync();

    ensureFilesAndFoldersExist(['dir1', 'dir1/file1']);
    expect(inMemoryLogger.output, isEmpty);

    expect(
      () => ensureFilesAndFoldersExist(['dir1', 'dir1/file2']),
      throwsA(isA<ExitException>()),
    );
    expect(inMemoryLogger.output, 'dir1/file2 does not exist');

    inMemoryLogger.clear();
    expect(
      () => ensureFilesAndFoldersExist(['dir2', 'dir2/file3']),
      throwsA(isA<ExitException>()),
    );
    expect(inMemoryLogger.output, 'dir2 does not exist');
  });
}

Matcher exceptionWithMessage(String message) {
  return throwsA(
    predicate((e) => e is Exception && e.toString().contains(message)),
  );
}
