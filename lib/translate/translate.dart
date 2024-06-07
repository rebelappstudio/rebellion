import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:collection/collection.dart';
import 'package:rebellion/analyze/checks/missing_translations.dart';
import 'package:rebellion/translate/translator.dart';
import 'package:rebellion/utils/extensions.dart';
import 'package:rebellion/utils/file_utils.dart';
import 'package:rebellion/utils/logger.dart';

const _provider = 'provider';

enum TranslationProvider {
  gpt4turbo('gpt-4-turbo'),
  gpt3_5turbo('gpt-3.5-turbo');

  final String optionName;

  const TranslationProvider(this.optionName);

  Translator get translator {
    return switch (this) {
      gpt4turbo => OpenAiTranslator(model: 'gpt-4-turbo'),
      gpt3_5turbo => OpenAiTranslator(model: 'gpt-3.5-turbo'),
    };
  }
}

class TranslateCommand extends Command {
  TranslateCommand() {
    argParser
      ..addOption(mainLocaleParam, defaultsTo: defaultMainLocale)
      ..addOption(
        _provider,
        defaultsTo: TranslationProvider.gpt4turbo.optionName,
        allowed: TranslationProvider.values.map((e) => e.optionName),
      );
  }

  @override
  String get name => 'translate';

  @override
  String get description => 'Translate missing translations using ChatGPT';

  @override
  Future<void> run() async {
    final translator = TranslationProvider.values
        .firstWhere((e) => e.optionName == argResults?[_provider] as String?)
        .translator;

    final options = loadOptionsYaml();
    final parsedFiles = getFilesAndFolders(options, argResults);
    final mainFile = parsedFiles.firstWhereOrNull((e) => e.file.isMainFile);
    if (mainFile == null) {
      logError("No main file found");
      exit(1);
    }
    final sourceLanguage = mainFile.file.locale;
    final missingTranslations = getMissingTranslations(parsedFiles);

    for (final file in missingTranslations) {
      final translations = <String, String>{};
      final targetLanguage = file.sourceFile.file.locale;

      for (final key in file.untranslatedKeys) {
        if (key.isAtKey) continue;
        if (key.isLocaleDefinition) continue;

        final translation = await translator.translate(
          sourceLanguage,
          targetLanguage,
          mainFile.content[key]!,
          mainFile.atKeyDescription(key),
        );
        translations[key] = translation;
      }

      final updatedFile = file.sourceFile.copyWith(
        content: {
          ...file.sourceFile.content,
          ...translations,
        },
      );
      writeArbFile(updatedFile.content, file.sourceFile.file.filepath);
    }
  }
}
