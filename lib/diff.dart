import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:collection/collection.dart';
import 'package:rebellion/checks/missing_translations.dart';
import 'package:rebellion/utils/file_utils.dart';
import 'package:rebellion/utils/logger.dart';

const _outputType = 'output';

enum OutputType {
  printToFile('file'),
  printToConsole('console');

  final String optionName;

  const OutputType(this.optionName);
}

class DiffCommand extends Command {
  DiffCommand() {
    argParser
      ..addOption(mainLocaleParam, defaultsTo: defaultMainLocale)
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
    final parsedFiles = getFilesAndFolders(argResults);
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
