import 'package:args/command_runner.dart';
import 'package:collection/collection.dart';
import 'package:rebellion/src/utils/arb_parser/parsed_arb_file.dart';
import 'package:rebellion/src/utils/extensions.dart';
import 'package:rebellion/src/utils/file_utils.dart';
import 'package:rebellion/src/utils/args.dart';
import 'package:rebellion/src/utils/logger.dart';
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
        help: CliArgs.sortingCliHelp,
      );
  }

  @override
  String get name => 'sort';

  @override
  String get description => CliArgs.sortDescription;

  @override
  String get invocation =>
      CliArgs.commandInvocation(runner!.executableName, name);

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

    logVerbose('Main locale: ${options.mainLocale}');
    logVerbose('Sorting: ${sorting.optionName}');
    logVerbose('Sorting ${parsedFiles.length} files');
    for (final file in parsedFiles) {
      final mainLabel = file.file.isMainFile ? ' (main)' : '';
      logVerbose('Found ${file.file.filepath}$mainLabel');
    }

    final sortedFiles = switch (sorting) {
      Sorting.alphabetical => _sortAlphabetically(parsedFiles, reverse: false),
      Sorting.alphabeticalReverse => _sortAlphabetically(
        parsedFiles,
        reverse: true,
      ),
      Sorting.followMainFile => _sortFollowingMainFile(parsedFiles),
    };
    for (final file in sortedFiles) {
      logVerbose('Sorted ${file.file.filepath}');
      writeArbFile(file.content, file.file.filepath);
    }
  }

  List<ParsedArbFile> _sortAlphabetically(
    List<ParsedArbFile> files, {
    required bool reverse,
  }) {
    final result = <ParsedArbFile>[];

    for (final file in files) {
      final sortedKeys = _orderArbKeys(file.keys, reverse: reverse);
      final fileContent = {
        for (final key in sortedKeys) key: file.content[key],
      };
      result.add(file.copyWithContent(fileContent));
    }

    return result;
  }

  List<ParsedArbFile> _sortFollowingMainFile(List<ParsedArbFile> files) {
    final mainFile = files.firstWhere((e) => e.file.isMainFile);
    final mainKeys = mainFile.keys;
    final mainKeySet = mainKeys.toSet();

    final result = <ParsedArbFile>[];
    for (final file in files) {
      if (file.file.isMainFile) {
        result.add(file);
        continue;
      }

      final ordered = [
        for (final key in mainKeys)
          if (file.keys.contains(key)) key,
      ];
      final extras = [
        for (final key in file.keys)
          if (!mainKeySet.contains(key)) key,
      ];
      final sortedKeys = [...ordered, ...extras];
      result.add(
        file.copyWithContent({
          for (final key in sortedKeys) key: file.content[key],
        }),
      );
    }

    return result;
  }
}

/// Orders ARB keys: @@-global-keys first, then message pairs as 'key' then '@key'.
List<String> _orderArbKeys(Iterable<String> keys, {bool reverse = false}) {
  final globals = <String>[];
  final regularKeys = <String>{};
  final atKeysByBase = <String, String>{};

  for (final key in keys) {
    if (key.isGlobalKey) {
      globals.add(key);
    } else if (key.isAtKey) {
      atKeysByBase[key.atKeyToRegularKey] = key;
    } else {
      regularKeys.add(key);
    }
  }

  globals.sort();

  var bases = {...regularKeys, ...atKeysByBase.keys}.toList()..sort();
  if (reverse) {
    bases = bases.reversed.toList();
  }

  return [
    ...globals,
    for (final base in bases) ...[
      if (regularKeys.contains(base)) base,
      if (atKeysByBase.containsKey(base)) atKeysByBase[base]!,
    ],
  ];
}
