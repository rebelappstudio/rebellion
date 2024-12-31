import 'package:args/command_runner.dart';
import 'package:collection/collection.dart';
import 'package:rebellion/src/analyze/analyzer_options.dart';
import 'package:rebellion/src/utils/file_utils.dart';
import 'package:rebellion/src/utils/logger.dart';
import 'package:rebellion/src/utils/exit_exception.dart';
import 'package:rebellion/src/utils/args.dart';
import 'package:rebellion/src/utils/rebellion_options.dart';

/// Analyze ARB files and report any found issues
///
/// List of files and rules to check against are based on [argResults]
class AnalyzeCommand extends Command {
  /// Default constructor
  AnalyzeCommand() {
    argParser.addOption(
      CliArgs.mainLocaleParam,
      defaultsTo: defaultMainLocale,
      valueHelp: CliArgs.mainLocaleCliValueHelp,
      help: CliArgs.mainLocaleCliHelp,
    );
  }

  @override
  String get description => 'Analyze ARB file(s)';

  @override
  String get name => 'analyze';

  @override
  List<String> get aliases => ['analyse'];

  @override
  void run() {
    // Create options from YAML file and CLI arguments
    final yamlOptions = RebellionOptions.loadYaml();
    final cliOptions = RebellionOptions.fromCliArguments(argResults);
    final options = yamlOptions.applyCliArguments(cliOptions);

    // final options = RebellionOptions.fromYaml(argResults, yamlOptions);
    final parsedFiles = getFilesAndFolders(options, argResults);
    final enabledRules = options.enabledRules.map((r) => r.rule);
    final analyzerOptions = AnalyzerOptions.fromFiles(
      rebellionOptions: options,
      files: parsedFiles,
    );

    // Check if main file is available
    if (!analyzerOptions.containsMainFile) {
      if (analyzerOptions.isSingleFile) {
        logMessage(
          '⚠️ Looks like a single file is being analyzed but it\'s not '
          'marked as the main file. Some checks may not work. '
          'Use the `${CliArgs.mainLocaleParam}` option '
          'to specify the main locale',
        );
      } else {
        logMessage(
          '⚠️ No main file found, some checks may not work. '
          'Use the `${CliArgs.mainLocaleParam}` option '
          'to specify the main locale',
        );
      }
    }

    final issuesFound =
        enabledRules.map((rule) => rule.run(parsedFiles, analyzerOptions)).sum;

    if (issuesFound > 0) {
      logMessage('');
      logError(
        issuesFound == 1 ? '1 issue found' : '$issuesFound issues found',
      );
      throw ExitException();
    } else {
      logMessage('No issues found');
    }
  }
}
