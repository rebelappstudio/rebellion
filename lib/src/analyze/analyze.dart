import 'package:args/command_runner.dart';
import 'package:rebellion/src/analyze/analyzer_options.dart';
import 'package:rebellion/src/utils/arb_parser/parsed_arb_file.dart';
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
  String get description => CliArgs.analyzeDescription;

  @override
  String get name => 'analyze';

  @override
  String get invocation =>
      CliArgs.commandInvocation(runner!.executableName, name);

  @override
  List<String> get aliases => ['analyse'];

  @override
  void run() {
    // Create options from YAML file and CLI arguments
    final yamlOptions = RebellionOptions.loadYaml();
    final cliOptions = RebellionOptions.fromCliArguments(argResults);
    final options = yamlOptions.applyCliArguments(cliOptions);

    final parsedFiles = getFilesAndFolders(options, argResults);
    final analyzerOptions = AnalyzerOptions.fromFiles(
      rebellionOptions: options,
      files: parsedFiles,
    );

    _logVerbosePipeline(options, parsedFiles);

    // Check if main file is available
    if (!analyzerOptions.containsMainFile) {
      if (analyzerOptions.isSingleFile) {
        logWarning(
          '⚠️ Looks like a single file is being analyzed but it\'s not '
          'marked as the main file. Some checks may not work. '
          'Use the `${CliArgs.mainLocaleParam}` option '
          'to specify the main locale',
        );
      } else {
        logWarning(
          '⚠️ No main file found, some checks may not work. '
          'Use the `${CliArgs.mainLocaleParam}` option '
          'to specify the main locale',
        );
      }
    }

    var issuesFound = 0;
    for (final ruleKey in options.enabledRules) {
      logVerbose('Checking ${ruleKey.key}');
      issuesFound += ruleKey.rule.run(parsedFiles, analyzerOptions);
    }

    if (issuesFound > 0) {
      logMessage('');
      logError(
        issuesFound == 1 ? '1 issue found' : '$issuesFound issues found',
      );
      throw ExitException();
    } else {
      logSuccess('No issues found');
    }
  }

  void _logVerbosePipeline(
    RebellionOptions options,
    List<ParsedArbFile> parsedFiles,
  ) {
    logVerbose('Main locale: ${options.mainLocale}');
    logVerbose('Naming convention: ${options.namingConvention.optionName}');
    logVerbose(
      'Enabled rules: ${options.enabledRules.map((r) => r.key).join(', ')}',
    );
    logVerbose('Analyzing ${parsedFiles.length} files');
    for (final file in parsedFiles) {
      final mainLabel = file.file.isMainFile ? ' (main)' : '';
      logVerbose('Found ${file.file.filepath}$mainLabel');
    }
  }
}
