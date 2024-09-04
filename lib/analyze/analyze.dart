import 'package:args/command_runner.dart';
import 'package:collection/collection.dart';
import 'package:rebellion/utils/file_utils.dart';
import 'package:rebellion/utils/logger.dart';
import 'package:rebellion/utils/exit_exception.dart';

class AnalyzeCommand extends Command {
  @override
  String get description => 'Analyze ARB file(s)';

  @override
  String get name => 'analyze';

  @override
  void run() {
    final options = loadOptionsYaml();
    final parsedFiles = getFilesAndFolders(options, argResults);
    final enabledChecks = options.enabledChecks();

    final issuesFound =
        enabledChecks.map((check) => check.run(parsedFiles, options)).sum;

    if (issuesFound > 0) {
      logError(
        issuesFound == 1 ? '1 issue found' : '$issuesFound issues found',
      );
      throw ExitException();
    } else {
      logMessage('No issues found');
    }
  }
}
