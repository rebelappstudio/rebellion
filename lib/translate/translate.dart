import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:collection/collection.dart';
import 'package:rebellion/checks/missing_translations.dart';
import 'package:rebellion/translate/translator.dart';
import 'package:rebellion/utils/file_utils.dart';
import 'package:rebellion/utils/logger.dart';

const _provider = 'provider';
const _accessKey = 'access-key';

enum TranslationProvider {
  gpt4('gpt-4-1106-preview');

  final String optionName;

  const TranslationProvider(this.optionName);

  Translator get translator {
    return switch (this) {
      gpt4 => OpenAiTranslator(model: 'gpt-4-1106-preview'),
    };
  }
}

class TranslateCommand extends Command {
  TranslateCommand() {
    argParser
      ..addOption(mainLocaleParam, defaultsTo: defaultMainLocale)
      ..addOption(_accessKey, mandatory: true)
      ..addOption(
        _provider,
        defaultsTo: TranslationProvider.gpt4.optionName,
        allowed: TranslationProvider.values.map((e) => e.optionName),
      );
  }

  @override
  String get name => 'translate';

  @override
  String get description => 'Translate missing translations using ChatGPT';

  @override
  Future<void> run() async {
    final accessKey = argResults?[_accessKey] as String?;
    final translator = TranslationProvider.values
        .firstWhere((e) => e.optionName == argResults?[_provider] as String?)
        .translator;

    if (accessKey == null || accessKey.isEmpty) {
      logError('Access key must be provided');
      exit(1);
    }

    final parsedFiles = getFilesAndFolders(argResults);
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
        final translation = await translator.translate(
          accessKey,
          sourceLanguage,
          targetLanguage,
          mainFile.content[key]!,
          null, // TODO provide context for better translations
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
