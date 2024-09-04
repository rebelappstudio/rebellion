import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as path;
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
import 'package:rebellion/analyze/checks/string_type.dart';
import 'package:rebellion/analyze/checks/unused_at_key.dart';
import 'package:rebellion/sort/sort.dart';
import 'package:rebellion/utils/arb_parser/arb_file.dart';
import 'package:rebellion/utils/arb_parser/arb_parser.dart';
import 'package:rebellion/utils/arb_parser/parsed_arb_file.dart';
import 'package:rebellion/utils/logger.dart';
import 'package:rebellion/utils/main_locale.dart';
import 'package:yaml/yaml.dart';

/// Get list of all .arb files except the main file
/// Returns list of tuples (Target language, ARB filename)
List<ArbFile> getArbFiles(List<String> filesAndFolders, String mainLocale) {
  final files = _getAllFiles(filesAndFolders);
  return files
      .map((file) {
        final filename = path.basenameWithoutExtension(file.path);

        // Ignore diff files
        if (filename.endsWith('_diff')) return null;

        // TODO this could be improved: e.g. 'en_US' doesn't work
        final locale = filename.substring(filename.lastIndexOf('_') + 1);

        return ArbFile(
          filepath: file.path,
          locale: locale,
          isMainFile: locale == mainLocale,
        );
      })
      .nonNulls
      .toList();
}

List<File> _getAllFiles(List<String> filesAndFolders) {
  final files = <File>[];
  for (final item in filesAndFolders) {
    final isFile = FileSystemEntity.isFileSync(item);
    if (isFile) {
      files.add(File(item));
    } else {
      final directory = Directory(item);
      files.addAll(directory.listSync().whereType<File>());
    }
  }

  return files;
}

List<ParsedArbFile> getFilesAndFolders(
  RebellionOptions options,
  ArgResults? argResults,
) {
  final mainLocale = options.mainLocale;
  final filesAndFolders = argResults?.rest ?? const [];
  _ensureFilesAndFoldersExist(filesAndFolders);

  return getArbFiles(filesAndFolders, mainLocale).map(parseArbFile).toList();
}

void writeArbFile(Map<String, dynamic> content, String filename) {
  final encoder = JsonEncoder.withIndent('  ');
  final jsonContent = encoder.convert(content);
  final file = File(filename);
  file.writeAsStringSync(jsonContent);
}

void writeArbFiles(List<ParsedArbFile> files) {
  for (final file in files) {
    writeArbFile(file.content, file.file.filepath);
  }
}

void _ensureFilesAndFoldersExist(List<String> filesAndFolders) {
  if (filesAndFolders.isEmpty) {
    logError('No files or folders to analyze');
    exit(1);
  }

  for (final item in filesAndFolders) {
    final itemExist = FileSystemEntity.isDirectorySync(item) ||
        FileSystemEntity.isFileSync(item);
    if (!itemExist) {
      logError('$item does not exist');
      exit(1);
    }
  }
}

RebellionOptions loadOptionsYaml() {
  final fileContent = File('rebellion_options.yaml').readAsStringSync();
  final yaml = loadYaml(fileContent) as YamlMap;

  final rules = yaml.nodes['rules'] as YamlList?;
  final options = yaml.nodes['options'] as YamlMap?;
  return RebellionOptions.fromYaml(rules, options);
}

class RebellionOptions {
  final bool allCapsCheckEnabled;
  final bool stringTypeCheckEnabled;
  final bool atKeyTypeCheckEnabled;
  final bool duplicatedKeysCheckEnabled;
  final bool emptyAtKeyCheckEnabled;
  final bool localeDefinitionCheckEnabled;
  final bool mandatoryAtKeyDescriptionCheckEnabled;
  final bool missingPlaceholdersCheckEnabled;
  final bool missingPluralsCheckEnabled;
  final bool missingTranslationsCheckEnabled;
  final bool namingConventionCheckEnabled;
  final bool redundantAtKeyCheckEnabled;
  final bool redundantTranslationsCheckEnabled;
  final bool unusedAtKeyCheckEnabled;

  final String mainLocale;
  final NamingConvention namingConvention;
  final Sorting sorting;

  const RebellionOptions._({
    required this.allCapsCheckEnabled,
    required this.stringTypeCheckEnabled,
    required this.atKeyTypeCheckEnabled,
    required this.duplicatedKeysCheckEnabled,
    required this.emptyAtKeyCheckEnabled,
    required this.localeDefinitionCheckEnabled,
    required this.mandatoryAtKeyDescriptionCheckEnabled,
    required this.missingPlaceholdersCheckEnabled,
    required this.missingPluralsCheckEnabled,
    required this.missingTranslationsCheckEnabled,
    required this.namingConventionCheckEnabled,
    required this.redundantAtKeyCheckEnabled,
    required this.redundantTranslationsCheckEnabled,
    required this.unusedAtKeyCheckEnabled,
    required this.mainLocale,
    required this.namingConvention,
    required this.sorting,
  });

  factory RebellionOptions.fromYaml(
    YamlList? rules,
    YamlMap? options,
  ) {
    return RebellionOptions._(
      allCapsCheckEnabled: rules?.contains('all_caps') ?? true,
      stringTypeCheckEnabled: rules?.contains('string_type') ?? true,
      atKeyTypeCheckEnabled: rules?.contains('at_key_type') ?? true,
      duplicatedKeysCheckEnabled: rules?.contains('duplicated_keys') ?? true,
      emptyAtKeyCheckEnabled: rules?.contains('empty_at_key') ?? true,
      localeDefinitionCheckEnabled:
          rules?.contains('locale_definition') ?? true,
      mandatoryAtKeyDescriptionCheckEnabled:
          rules?.contains('mandatory_at_key_description') ?? false,
      missingPlaceholdersCheckEnabled:
          rules?.contains('missing_placeholders') ?? true,
      missingPluralsCheckEnabled: rules?.contains('missing_plurals') ?? true,
      missingTranslationsCheckEnabled:
          rules?.contains('missing_translations') ?? true,
      namingConventionCheckEnabled:
          rules?.contains('naming_convention') ?? true,
      redundantAtKeyCheckEnabled: rules?.contains('redundant_at_key') ?? true,
      redundantTranslationsCheckEnabled:
          rules?.contains('redundant_translations') ?? true,
      unusedAtKeyCheckEnabled: rules?.contains('unused_at_key') ?? true,
      mainLocale: options?['main_locale'] as String? ?? defaultMainLocale,
      namingConvention: NamingConvention.fromOptionName(
              options?['naming_convention'] as String) ??
          NamingConvention.camel,
      sorting:
          Sorting.fromOptionName(options?['sorting']) ?? Sorting.alphabetical,
    );
  }

  List<CheckBase> enabledChecks() {
    return <CheckBase>[
      if (stringTypeCheckEnabled) const StringType(),
      if (atKeyTypeCheckEnabled) const AtKeyType(),
      if (allCapsCheckEnabled) const AllCaps(),
      if (duplicatedKeysCheckEnabled) const DuplicatedKeys(),
      if (emptyAtKeyCheckEnabled) const EmptyAtKeys(),
      if (localeDefinitionCheckEnabled) const LocaleDefinitionPresent(),
      if (mandatoryAtKeyDescriptionCheckEnabled)
        const MandatoryKeyDescription(),
      if (missingPlaceholdersCheckEnabled) const MissingPlaceholders(),
      if (missingPluralsCheckEnabled) const MissingPlurals(),
      if (missingTranslationsCheckEnabled) const MissingTranslations(),
      if (redundantAtKeyCheckEnabled) const RedundantAtKey(),
      if (redundantTranslationsCheckEnabled) const RedundantTranslations(),
      if (unusedAtKeyCheckEnabled) const UnusedAtKey(),
      if (namingConventionCheckEnabled) const NamingConventionCheck(),
    ];
  }
}
