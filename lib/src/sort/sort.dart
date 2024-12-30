import 'package:args/command_runner.dart';
import 'package:collection/collection.dart';
import 'package:rebellion/src/utils/arb_parser/parsed_arb_file.dart';
import 'package:rebellion/src/utils/extensions.dart';
import 'package:rebellion/src/utils/file_utils.dart';
import 'package:rebellion/src/utils/args.dart';
import 'package:rebellion/src/utils/rebellion_options.dart';

/// Sorting options
enum Sorting {
  /// Sort keys alphabetically
  alphabetical('alphabetical'),

  /// Sort keys in reverse alphabetical order
  alphabeticalReverse('alphabetical-reverse'),

  /// Sort keys following the main file key order
  followMainFile('follow-main-file');

  /// CLI option name
  final String optionName;

  const Sorting(this.optionName);

  /// Get [Sorting] from CLI option name
  static Sorting? fromOptionName(String? optionName) {
    return Sorting.values.firstWhereOrNull((e) => e.optionName == optionName);
  }
}

/// Sort keys of ARB files
class SortCommand extends Command {
  /// Default constructor
  SortCommand() {
    argParser
      ..addOption(
        CliArgs.mainLocaleParam,
        defaultsTo: defaultMainLocale,
        valueHelp: CliArgs.mainLocaleCliValueHelp,
        help: CliArgs.mainLocaleCliHelp,
      )
      ..addOption(
        CliArgs.sortingParam,
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
    // Create options from YAML file and CLI arguments
    final yamlOptions = RebellionOptions.loadYaml();
    final cliOptions = RebellionOptions.fromCliArguments(argResults);
    final options = yamlOptions.applyCliArguments(cliOptions);
    final sorting = Sorting.values.firstWhere(
      (e) => e.optionName == argResults?[CliArgs.sortingParam] as String,
    );

    final parsedFiles = getFilesAndFolders(options, argResults);
    final sortedFiles = switch (sorting) {
      Sorting.alphabetical => _sortAlphabetically(parsedFiles, reverse: false),
      Sorting.alphabeticalReverse =>
        _sortAlphabetically(parsedFiles, reverse: true),
      Sorting.followMainFile => _sortFollowingMainFile(parsedFiles),
    };
    for (final file in sortedFiles) {
      writeArbFile(file.content, file.file.filepath);
    }
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
        file.copyWithContent(fileContent),
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
        for (final key in mainKeys)
          if (file.keys.contains(key)) key: file.content[key],
      };
      result.add(
        file.copyWithContent(fileContent),
      );
    }

    return result;
  }
}
