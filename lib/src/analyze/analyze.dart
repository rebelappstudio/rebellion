import 'package:args/command_runner.dart';
import 'package:collection/collection.dart';
import 'package:rebellion/src/utils/file_utils.dart';
import 'package:rebellion/src/utils/logger.dart';
import 'package:rebellion/src/utils/exit_exception.dart';

/// Analyze ARB files and report any found issues
///
/// List of files and rules to check against are based on [argResults]
class AnalyzeCommand extends Command {
  @override
  String get description => 'Analyze ARB file(s)';

  @override
  String get name => 'analyze';

  @override
  List<String> get aliases => ['analyse'];

  @override
  void run() {
    final options = loadOptionsYaml();
    final parsedFiles = getFilesAndFolders(options, argResults);
    final enabledRules = options.enabledRules();

    final issuesFound =
        enabledRules.map((rule) => rule.run(parsedFiles, options)).sum;

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
