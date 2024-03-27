import 'package:args/command_runner.dart';
import 'package:rebellion/utils/file_utils.dart';

const _sortingParam = 'sorting';

enum Sorting {
  alphabetical('alphabetical'),
  alphabeticalReverse('alphabetical-reverse'),
  followMainFile('follow-main-file');

  final String optionName;

  const Sorting(this.optionName);
}

/// TODO sort keys:
/// -alphabetical
/// -alphabetical-reverse
/// -follow-main-file
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
    final sorting = Sorting.values.firstWhere(
      (e) => e.optionName == argResults?[_sortingParam] as String,
    );

    final parsedFiles = getFilesAndFolders(argResults);
    switch (sorting) {
      case Sorting.alphabetical:
      case Sorting.alphabeticalReverse:
      case Sorting.followMainFile:
    }

    // TODO implement sorting
    // TODO sort main keys first then rest should follow (in case of follow-main-file option no need to sort main file)
    // TODO at-keys should be sorted after the string (option to change it?)
  }
}
