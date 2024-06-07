import 'package:args/command_runner.dart';
import 'package:collection/collection.dart';
import 'package:rebellion/utils/extensions.dart';
import 'package:rebellion/utils/file_utils.dart';

const _sortingParam = 'sorting';

enum Sorting {
  alphabetical('alphabetical'),
  alphabeticalReverse('alphabetical-reverse'),
  followMainFile('follow-main-file');

  final String optionName;

  const Sorting(this.optionName);

  static Sorting? fromOptionName(String? optionName) {
    return Sorting.values.firstWhere((e) => e.optionName == optionName);
  }
}

class SortCommand extends Command {
  SortCommand() {
    argParser
      ..addOption(mainLocaleParam, defaultsTo: defaultMainLocale)
      ..addOption(
        _sortingParam,
        defaultsTo: Sorting.alphabetical.optionName,
        allowed: Sorting.values.map((e) => e.optionName),
      );
  }

  @override
  String get name => 'sort';

  @override
  String get description => 'Sort keys of ARB files';

  @override
  void run() {
    final options = loadOptionsYaml();
    final sorting = Sorting.values.firstWhere(
      (e) => e.optionName == argResults?[_sortingParam] as String,
    );

    final parsedFiles = getFilesAndFolders(options, argResults);
    final sortedFiles = switch (sorting) {
      Sorting.alphabetical => _sortAlphabetically(parsedFiles, reverse: false),
      Sorting.alphabeticalReverse =>
        _sortAlphabetically(parsedFiles, reverse: true),
      Sorting.followMainFile => _sortFollowingMainFile(parsedFiles),
    };
    writeArbFiles(sortedFiles);
  }

  List<ParsedArbFile> _sortAlphabetically(
    List<ParsedArbFile> files, {
    required bool reverse,
  }) {
    final result = <ParsedArbFile>[];

    for (final file in files) {
      var sortedKeys = file.keys.sortedBy((e) {
        // Place at-keys near the original string.
        // This may not be ideal as it keeps the original order of at-keys, e.g.
        // at-key is placed before the key if it's placed like that in the
        // original unsorted file
        if (e.isAtKey) return e.atKeyToRegularKey;

        return e;
      });
      sortedKeys = reverse ? sortedKeys.reversed.toList() : sortedKeys;

      final fileContent = {
        for (final key in sortedKeys) key: file.content[key],
      };
      result.add(
        file.copyWith(content: fileContent),
      );
    }

    return result;
  }

  List<ParsedArbFile> _sortFollowingMainFile(List<ParsedArbFile> files) {
    final mainFile = files.firstWhere((e) => e.file.isMainFile);
    final mainKeys = mainFile.keys;

    final result = <ParsedArbFile>[];
    for (final file in files) {
      if (file.file.isMainFile) {
        result.add(file);
        continue;
      }

      final fileContent = {
        for (final key in mainKeys) key: file.content[key],
      };
      result.add(
        file.copyWith(content: fileContent),
      );
    }

    return result;
  }
}
