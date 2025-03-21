import 'package:args/command_runner.dart';
import 'package:rebellion/src/utils/diff_utils.dart';
import 'package:rebellion/src/utils/file_utils.dart';
import 'package:rebellion/src/utils/logger.dart';
import 'package:rebellion/src/utils/args.dart';
import 'package:rebellion/src/utils/rebellion_options.dart';

const _outputType = 'output';

/// Output type for the diff command
enum OutputType {
  /// Crate a "diff" ARB file with missing translations
  printToFile('file'),

  /// Print missing translations to the console
  printToConsole('console');

  /// CLI option name
  final String optionName;

  const OutputType(this.optionName);
}

/// Collect missing translations by comparing main ARB file with other ARB files
class DiffCommand extends Command {
  /// Default constructor
  DiffCommand() {
    argParser
      ..addOption(
        CliArgs.mainLocaleParam,
        defaultsTo: defaultMainLocale,
        valueHelp: CliArgs.mainLocaleCliValueHelp,
        help: CliArgs.mainLocaleCliHelp,
      )
      ..addOption(
        _outputType,
        defaultsTo: OutputType.printToConsole.optionName,
        allowed: OutputType.values.map((e) => e.optionName),
      );
  }

  @override
  String get name => 'diff';

  @override
  String get description => 'Collect missing translations';

  @override
  void run() {
    // Create options from YAML file and CLI arguments
    final yamlOptions = RebellionOptions.loadYaml();
    final cliOptions = RebellionOptions.fromCliArguments(argResults);
    final options = yamlOptions.applyCliArguments(cliOptions);
    final parsedFiles = getFilesAndFolders(options, argResults);
    final outputType = OutputType.values.firstWhere(
      (e) => e.optionName == argResults?[_outputType] as String?,
    );

    final missingTranslations = getMissingTranslations(parsedFiles);
    if (missingTranslations.isEmpty) {
      logMessage('No missing translations found');
      return;
    }

    for (final file in missingTranslations) {
      switch (outputType) {
        case OutputType.printToFile:
          _writeDiffArbFile(file);
        case OutputType.printToConsole:
          _printMissingTranslations(file);
      }
    }
  }

  void _writeDiffArbFile(DiffArbFile file) {
    final fileContent = {
      for (final key in file.untranslatedKeys) key: '',
    };
    final outputFile = file.sourceFile.file.filepath.replaceAll(
      '.arb',
      '_diff.arb',
    );
    writeArbFile(fileContent, outputFile);
  }

  void _printMissingTranslations(DiffArbFile file) {
    logMessage(
      '${file.sourceFile.file.filepath}: ${file.untranslatedKeys.length} missing translations:',
    );
    for (final key in file.untranslatedKeys) {
      logMessage(' - $key');
    }
  }
}
