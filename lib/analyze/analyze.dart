import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:collection/collection.dart';
import 'package:rebellion/utils/file_utils.dart';
import 'package:rebellion/utils/logger.dart';

// TODO yaml configuration file (which checks to run). Or use analysis_options.yaml
// TODO lint using custom_lint or similar
// TODO tests
// TODO CI
// TODO README
// TODO publish
// TODO package export (rebellion.dart)
// TODO better 'help' for each flag
// TODO logging with --verbose
// TODO new check: hardcoded strings (l10nization_cli)
// TODO new check: unused translations (string_literal_finder lib)
// TODO topics
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
      exit(1);
    } else {
      logMessage('No issues found');
    }
  }
}
