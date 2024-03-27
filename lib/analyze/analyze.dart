import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:collection/collection.dart';
import 'package:rebellion/analyze/checks/all_caps.dart';
import 'package:rebellion/analyze/checks/at_key_type.dart';
import 'package:rebellion/analyze/checks/check_base.dart';
import 'package:rebellion/analyze/checks/duplicate_keys.dart';
import 'package:rebellion/analyze/checks/empty_at_key.dart';
import 'package:rebellion/analyze/checks/locale_definition.dart';
import 'package:rebellion/analyze/checks/mandatory_key_description.dart';
import 'package:rebellion/analyze/checks/missing_placeholders.dart';
import 'package:rebellion/analyze/checks/missing_plurals.dart';
import 'package:rebellion/analyze/checks/missing_translations.dart';
import 'package:rebellion/analyze/checks/naming_convention.dart';
import 'package:rebellion/analyze/checks/redundant_at_key.dart';
import 'package:rebellion/analyze/checks/redundant_translations.dart';
import 'package:rebellion/analyze/checks/unused_at_key.dart';
import 'package:rebellion/icu_parser/icu_parser.dart';
import 'package:rebellion/utils/file_utils.dart';
import 'package:rebellion/utils/logger.dart';

const _flagChecks = <CheckBase>[
  AllCaps(),
  AtKeyType(),
  DuplicatedKeys(),
  EmptyAtKeys(),
  LocaleDefinitionPresent(),
  MandatoryKeyDescription(),
  MissingPlaceholders(),
  MissingPlurals(),
  MissingTranslations(),
  RedundantAtKey(),
  RedundantTranslations(),
  UnusedAtKey(),
];

final _optionChecks = <OptionCheckBase>[
  NamingConventionCheck(),
];

// TODO yaml configuration file (which checks to run). Or use analisys_options.yaml
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
  AnalyzeCommand() {
    argParser.addOption(mainLocaleParam, defaultsTo: defaultMainLocale);

    // Register all flag-like checks
    for (final check in _flagChecks) {
      argParser.addFlag(
        check.optionName,
        defaultsTo: check.defaultsTo,
      );
    }

    // Register all option-like checks
    for (final check in _optionChecks) {
      argParser.addOption(
        check.optionName,
        defaultsTo: check.defaultsTo,
        allowed: check.allowedValues,
      );
    }
  }

  @override
  String get description => 'Analyze ARB file(s)';

  @override
  String get name => 'analyze';

  @override
  void run() {
    final parsedFiles = getFilesAndFolders(argResults);
    final enabledChecks = _flagChecks.where((check) {
      return argResults?[check.optionName] == true;
    });

    final icuParser = IcuParser();
    final issuesFound =
        enabledChecks.map((check) => check.run(icuParser, parsedFiles)).sum;

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
