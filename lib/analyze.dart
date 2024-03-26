import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:rebellion/checks/all_caps.dart';
import 'package:rebellion/checks/at_key_type.dart';
import 'package:rebellion/checks/duplicate_keys.dart';
import 'package:rebellion/checks/empty_at_key.dart';
import 'package:rebellion/checks/locale_definition.dart';
import 'package:rebellion/checks/mandatory_key_description.dart';
import 'package:rebellion/checks/missing_placeholders.dart';
import 'package:rebellion/checks/missing_plurals.dart';
import 'package:rebellion/checks/missing_translations.dart';
import 'package:rebellion/checks/naming_convention.dart';
import 'package:rebellion/checks/redundant_at_key.dart';
import 'package:rebellion/checks/redundant_translations.dart';
import 'package:rebellion/checks/unused_at_key.dart';
import 'package:rebellion/utils/file_utils.dart';
import 'package:rebellion/utils/logger.dart';

/// Check if there are duplicate keys
const _duplicatedKeys = 'duplicated-keys';

/// Check if there are all caps strings. This considered to be a bad practice.
/// It's better to convert to all caps programmatically
const _allCaps = 'all-caps';

/// Check if there are missing translations (translation files miss some keys
/// present in the main file)
const _missingTranslations = 'missing-translations';

/// Check if there are unnecessary translations (translation files contain
/// keys not present in the main file)
const _redundantTranslations = 'redundant-translations';

/// Translation file contains @-keys without specifying the data type of the
/// placeholders
const _missingPlaceholders = 'missing-placeholders';

/// Check if there are missing plurals in original and translation
const _missingPlurals = 'missing-plurals';

/// Translation file contains @@locale key with locale definition
const _localeDefinition = 'locale-definition';

/// At key (string that starts with @) must be a JSON object
const _atKeyType = 'at-key-type';

/// Translations contain @-keys without content
const _emptyAtKey = 'empty-at-key';

/// @-keys must have description for the corresponding key
const _mandatoryAtKeyDescription = 'mandatory-at-key-description';

/// At-key has no corresponding key
const _atKeyWithoutKey = 'at-key-without-key';

/// Translation files contain @-keys with data already present in the main file
const _redundantAtKey = 'redundant-at-key';

/// Check if keys are camelCase or snake_case
const _namingConvention = 'naming-convention';

// TODO yaml file for configuration
// TODO lint using custom_lint
// TODO tests
// TODO CI
// TODO README
// TODO publish
// TODO better help messages
// TODO package export (rebellion.dart)
// TODO better 'help' for each flag
// TODO logging with --verbose
class AnalyzeCommand extends Command {
  AnalyzeCommand() {
    argParser
      ..addFlag(_missingTranslations, defaultsTo: true)
      ..addFlag(_redundantTranslations, defaultsTo: true)
      ..addFlag(_redundantAtKey, defaultsTo: true)
      ..addFlag(_duplicatedKeys, defaultsTo: true)
      ..addFlag(_allCaps, defaultsTo: true)
      ..addFlag(_missingPlurals, defaultsTo: true)
      ..addFlag(_localeDefinition, defaultsTo: true)
      ..addFlag(_emptyAtKey, defaultsTo: true)
      ..addFlag(_atKeyWithoutKey, defaultsTo: true)
      ..addFlag(_atKeyType, defaultsTo: true)
      ..addFlag(_missingPlaceholders, defaultsTo: true)
      ..addFlag(_mandatoryAtKeyDescription, defaultsTo: false)
      ..addOption(mainLocaleParam, defaultsTo: defaultMainLocale)
      ..addOption(
        _namingConvention,
        defaultsTo: NamingConvention.camel.optionName,
        allowed: NamingConvention.values.map((e) => e.optionName),
      );
  }

  @override
  String get description => 'Analyze ARB file(s)';

  @override
  String get name => 'analyze';

  @override
  void run() {
    final parsedFiles = getFilesAndFolders(argResults);
    bool passed = true;

    if (argResults?[_localeDefinition] == true) {
      passed = checkLocaleDefinition(parsedFiles) && passed;
    }

    if (argResults?[_duplicatedKeys] == true) {
      passed = checkDuplicatedKeys(parsedFiles) && passed;
    }

    if (argResults?[_allCaps] == true) {
      passed = checkAllCapsStrings(parsedFiles) && passed;
    }

    if (argResults?[_atKeyType] == true) {
      passed = checkAtKeyType(parsedFiles) && passed;
    }

    if (argResults?[_emptyAtKey] == true) {
      passed = checkEmptyAtKey(parsedFiles) && passed;
    }

    if (argResults?[_atKeyWithoutKey] == true) {
      passed = checkUnusedAtKey(parsedFiles) && passed;
    }

    if (argResults?[_mandatoryAtKeyDescription] == true) {
      passed = checkMandatoryKeyDescription(parsedFiles) && passed;
    }

    if (argResults?[_missingTranslations] == true) {
      passed = checkMissingTranslations(parsedFiles) && passed;
    }

    if (argResults?[_redundantTranslations] == true) {
      passed = checkRedundantTranslations(parsedFiles) && passed;
    }

    if (argResults?[_missingPlaceholders] == true) {
      passed = checkMissingPlaceholders(parsedFiles) && passed;
    }

    if (argResults?[_missingPlurals] == true) {
      passed = checkMissingPlurals(parsedFiles) && passed;
    }

    if (argResults?[_redundantAtKey] == true) {
      passed = checkRedundantAtKey(parsedFiles) && passed;
    }

    if (argResults?[_namingConvention] != null) {
      final convention = NamingConvention.fromOptionName(
        argResults?[_namingConvention],
      );
      passed = checkKeyNamingConvention(parsedFiles, convention) && passed;
    }

    if (!passed) {
      logError('Some checks failed');
      exit(1);
    } else {
      logMessage('No issues found');
    }
  }
}
