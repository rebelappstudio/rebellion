import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:rebellion/src/analyze/analyze.dart';
import 'package:rebellion/src/diff/diff.dart';
import 'package:rebellion/src/sort/sort.dart';
import 'package:rebellion/src/utils/args.dart';
import 'package:rebellion/src/utils/logger.dart';

/// A [CommandRunner] for the rebellion CLI tool
final commandRunner = RebellionCommandRunner();

/// Rebellion CLI [CommandRunner] with global flags
class RebellionCommandRunner extends CommandRunner<void> {
  /// Default constructor
  RebellionCommandRunner()
    : super(
        'rebellion',
        'Set of CLI tools for analyzing and translating ARB files',
      ) {
    argParser.addFlag(
      CliArgs.verboseParam,
      abbr: 'v',
      negatable: false,
      help: CliArgs.verboseCliHelp,
    );
    addCommand(AnalyzeCommand());
    addCommand(DiffCommand());
    addCommand(SortCommand());
  }

  @override
  Future<void> runCommand(ArgResults topLevelResults) async {
    configureLogger(verbose: topLevelResults.flag(CliArgs.verboseParam));
    await super.runCommand(topLevelResults);
  }
}
