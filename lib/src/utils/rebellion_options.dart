import 'package:args/args.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:rebellion/src/analyze/rules/all_caps.dart';
import 'package:rebellion/src/analyze/rules/at_key_type.dart';
import 'package:rebellion/src/analyze/rules/duplicate_keys.dart';
import 'package:rebellion/src/analyze/rules/empty_at_key.dart';
import 'package:rebellion/src/analyze/rules/locale_definition.dart';
import 'package:rebellion/src/analyze/rules/mandatory_key_description.dart';
import 'package:rebellion/src/analyze/rules/missing_placeholders.dart';
import 'package:rebellion/src/analyze/rules/missing_plurals.dart';
import 'package:rebellion/src/analyze/rules/missing_translations.dart';
import 'package:rebellion/src/analyze/rules/naming_convention.dart';
import 'package:rebellion/src/analyze/rules/redundant_at_key.dart';
import 'package:rebellion/src/analyze/rules/redundant_translations.dart';
import 'package:rebellion/src/analyze/rules/rule.dart';
import 'package:rebellion/src/analyze/rules/string_type.dart';
import 'package:rebellion/src/analyze/rules/unused_at_key.dart';
import 'package:rebellion/src/sort/sort.dart';
import 'package:rebellion/src/utils/args.dart';
import 'package:rebellion/src/utils/file_reader.dart';
import 'package:yaml/yaml.dart';

/// Filename of the configuration YAML file
@visibleForTesting
const configFilename = 'rebellion_options.yaml';

/// Options for the rebellion tool
class RebellionOptions with EquatableMixin {
  /// True if [AllCaps] rule is enabled
  final bool allCapsRuleEnabled;

  /// True if [StringType] rule is enabled
  final bool stringTypeRuleEnabled;

  /// True if [AtKeyType] rule is enabled
  final bool atKeyTypeRuleEnabled;

  /// True if [DuplicatedKeys] rule is enabled
  final bool duplicatedKeysRuleEnabled;

  /// True if [EmptyAtKeys] rule is enabled
  final bool emptyAtKeyRuleEnabled;

  /// True if [LocaleDefinitionPresent] rule is enabled
  final bool localeDefinitionRuleEnabled;

  /// True if [MandatoryKeyDescription] rule is enabled
  final bool mandatoryAtKeyDescriptionRuleEnabled;

  /// True if [MissingPlaceholders] rule is enabled
  final bool missingPlaceholdersRuleEnabled;

  /// True if [MissingPlurals] rule is enabled
  final bool missingPluralsRuleEnabled;

  /// True if [MissingTranslations] rule is enabled
  final bool missingTranslationsRuleEnabled;

  /// True if [NamingConventionRule] rule is enabled
  final bool namingConventionRuleEnabled;

  /// True if [RedundantAtKey] rule is enabled
  final bool redundantAtKeyRuleEnabled;

  /// True if [RedundantTranslations] rule is enabled
  final bool redundantTranslationsRuleEnabled;

  /// True if [UnusedAtKey] rule is enabled
  final bool unusedAtKeyRuleEnabled;

  /// Default locale of the project
  final String mainLocale;

  /// Naming convention for keys
  final NamingConvention namingConvention;

  /// Sorting of keys
  final Sorting sorting;

  /// Default constructor
  @visibleForTesting
  const RebellionOptions({
    required bool? allCapsRuleEnabled,
    required bool? stringTypeRuleEnabled,
    required bool? atKeyTypeRuleEnabled,
    required bool? duplicatedKeysRuleEnabled,
    required bool? emptyAtKeyRuleEnabled,
    required bool? localeDefinitionRuleEnabled,
    required bool? mandatoryAtKeyDescriptionRuleEnabled,
    required bool? missingPlaceholdersRuleEnabled,
    required bool? missingPluralsRuleEnabled,
    required bool? missingTranslationsRuleEnabled,
    required bool? namingConventionRuleEnabled,
    required bool? redundantAtKeyRuleEnabled,
    required bool? redundantTranslationsRuleEnabled,
    required bool? unusedAtKeyRuleEnabled,
    required String? mainLocale,
    required NamingConvention? namingConvention,
    required Sorting? sorting,
  })  : allCapsRuleEnabled = allCapsRuleEnabled ?? true,
        stringTypeRuleEnabled = stringTypeRuleEnabled ?? true,
        atKeyTypeRuleEnabled = atKeyTypeRuleEnabled ?? true,
        duplicatedKeysRuleEnabled = duplicatedKeysRuleEnabled ?? true,
        emptyAtKeyRuleEnabled = emptyAtKeyRuleEnabled ?? true,
        localeDefinitionRuleEnabled = localeDefinitionRuleEnabled ?? true,
        mandatoryAtKeyDescriptionRuleEnabled =
            mandatoryAtKeyDescriptionRuleEnabled ?? false,
        missingPlaceholdersRuleEnabled = missingPlaceholdersRuleEnabled ?? true,
        missingPluralsRuleEnabled = missingPluralsRuleEnabled ?? true,
        missingTranslationsRuleEnabled = missingTranslationsRuleEnabled ?? true,
        namingConventionRuleEnabled = namingConventionRuleEnabled ?? true,
        redundantAtKeyRuleEnabled = redundantAtKeyRuleEnabled ?? true,
        redundantTranslationsRuleEnabled =
            redundantTranslationsRuleEnabled ?? true,
        unusedAtKeyRuleEnabled = unusedAtKeyRuleEnabled ?? true,
        mainLocale = mainLocale ?? defaultMainLocale,
        namingConvention = namingConvention ?? NamingConvention.camel,
        sorting = sorting ?? Sorting.alphabetical;

  /// Default empty constructor
  factory RebellionOptions.empty() {
    return RebellionOptions(
      allCapsRuleEnabled: null,
      stringTypeRuleEnabled: null,
      atKeyTypeRuleEnabled: null,
      duplicatedKeysRuleEnabled: null,
      emptyAtKeyRuleEnabled: null,
      localeDefinitionRuleEnabled: null,
      mandatoryAtKeyDescriptionRuleEnabled: null,
      missingPlaceholdersRuleEnabled: null,
      missingPluralsRuleEnabled: null,
      missingTranslationsRuleEnabled: null,
      namingConventionRuleEnabled: null,
      redundantAtKeyRuleEnabled: null,
      redundantTranslationsRuleEnabled: null,
      unusedAtKeyRuleEnabled: null,
      mainLocale: null,
      namingConvention: null,
      sorting: null,
    );
  }

  /// Create an instance of [RebellionOptions] from CLI arguments
  factory RebellionOptions.fromCliArguments(ArgResults? argResults) {
    return RebellionOptions(
      mainLocale: argResults?.option(CliArgs.mainLocaleParam),
      allCapsRuleEnabled: null,
      stringTypeRuleEnabled: null,
      atKeyTypeRuleEnabled: null,
      duplicatedKeysRuleEnabled: null,
      emptyAtKeyRuleEnabled: null,
      localeDefinitionRuleEnabled: null,
      mandatoryAtKeyDescriptionRuleEnabled: null,
      missingPlaceholdersRuleEnabled: null,
      missingPluralsRuleEnabled: null,
      missingTranslationsRuleEnabled: null,
      namingConventionRuleEnabled: null,
      redundantAtKeyRuleEnabled: null,
      redundantTranslationsRuleEnabled: null,
      unusedAtKeyRuleEnabled: null,
      namingConvention: null,
      sorting: null,
    );
  }

  /// Load configuration from a YAML file and create an instance of
  /// [RebellionOptions]
  factory RebellionOptions.loadYaml() {
    if (!fileReader.file(configFilename).existsSync()) {
      return RebellionOptions.empty();
    }

    final fileContent = fileReader.readFile(configFilename);
    final yaml = loadYaml(fileContent) as YamlMap;

    final rules = yaml.nodes['rules'] as YamlList?;
    final options = yaml.nodes['options'] as YamlMap?;

    return RebellionOptions(
      allCapsRuleEnabled: rules?.contains(YamlArgs.allCaps),
      stringTypeRuleEnabled: rules?.contains(YamlArgs.stringType),
      atKeyTypeRuleEnabled: rules?.contains(YamlArgs.atKeyType),
      duplicatedKeysRuleEnabled: rules?.contains(YamlArgs.duplicatedKeys),
      emptyAtKeyRuleEnabled: rules?.contains(YamlArgs.emptyAtKey),
      localeDefinitionRuleEnabled: rules?.contains(YamlArgs.localeDefinition),
      mandatoryAtKeyDescriptionRuleEnabled:
          rules?.contains(YamlArgs.mandatoryAtKeyDescription),
      missingPlaceholdersRuleEnabled:
          rules?.contains(YamlArgs.missingPlaceholders),
      missingPluralsRuleEnabled: rules?.contains(YamlArgs.missingPlurals),
      missingTranslationsRuleEnabled:
          rules?.contains(YamlArgs.missingTranslations),
      namingConventionRuleEnabled: rules?.contains(YamlArgs.namingConvention),
      redundantAtKeyRuleEnabled: rules?.contains(YamlArgs.redundantAtKey),
      redundantTranslationsRuleEnabled:
          rules?.contains(YamlArgs.redundantTranslations),
      unusedAtKeyRuleEnabled: rules?.contains(YamlArgs.unusedAtKey),
      mainLocale: options?[YamlArgs.mainLocale] as String?,
      namingConvention: NamingConvention.fromOptionName(
        options?[YamlArgs.namingConvention] as String?,
      ),
      sorting: Sorting.fromOptionName(options?[YamlArgs.sorting] as String?),
    );
  }

  /// Get a list of enabled rules
  List<Rule> enabledRules() {
    return <Rule>[
      if (stringTypeRuleEnabled) const StringType(),
      if (atKeyTypeRuleEnabled) const AtKeyType(),
      if (allCapsRuleEnabled) const AllCaps(),
      if (duplicatedKeysRuleEnabled) const DuplicatedKeys(),
      if (emptyAtKeyRuleEnabled) const EmptyAtKeys(),
      if (localeDefinitionRuleEnabled) const LocaleDefinitionPresent(),
      if (mandatoryAtKeyDescriptionRuleEnabled) const MandatoryKeyDescription(),
      if (missingPlaceholdersRuleEnabled) const MissingPlaceholders(),
      if (missingPluralsRuleEnabled) const MissingPlurals(),
      if (missingTranslationsRuleEnabled) const MissingTranslations(),
      if (redundantAtKeyRuleEnabled) const RedundantAtKey(),
      if (redundantTranslationsRuleEnabled) const RedundantTranslations(),
      if (unusedAtKeyRuleEnabled) const UnusedAtKey(),
      if (namingConventionRuleEnabled) const NamingConventionRule(),
    ];
  }

  @override
  List<Object?> get props => [
        allCapsRuleEnabled,
        stringTypeRuleEnabled,
        atKeyTypeRuleEnabled,
        duplicatedKeysRuleEnabled,
        emptyAtKeyRuleEnabled,
        localeDefinitionRuleEnabled,
        mandatoryAtKeyDescriptionRuleEnabled,
        missingPlaceholdersRuleEnabled,
        missingPluralsRuleEnabled,
        missingTranslationsRuleEnabled,
        namingConventionRuleEnabled,
        redundantAtKeyRuleEnabled,
        redundantTranslationsRuleEnabled,
        unusedAtKeyRuleEnabled,
        mainLocale,
        namingConvention,
        sorting,
      ];

  /// Apply CLI arguments [RebellionOptions] to the current options
  ///
  /// This copies main locale from the CLI arguments
  RebellionOptions applyCliArguments(RebellionOptions other) {
    return copyWith(mainLocale: other.mainLocale);
  }

  /// Copy the current [RebellionOptions] with new values
  RebellionOptions copyWith({
    bool? allCapsRuleEnabled,
    bool? stringTypeRuleEnabled,
    bool? atKeyTypeRuleEnabled,
    bool? duplicatedKeysRuleEnabled,
    bool? emptyAtKeyRuleEnabled,
    bool? localeDefinitionRuleEnabled,
    bool? mandatoryAtKeyDescriptionRuleEnabled,
    bool? missingPlaceholdersRuleEnabled,
    bool? missingPluralsRuleEnabled,
    bool? missingTranslationsRuleEnabled,
    bool? namingConventionRuleEnabled,
    bool? redundantAtKeyRuleEnabled,
    bool? redundantTranslationsRuleEnabled,
    bool? unusedAtKeyRuleEnabled,
    String? mainLocale,
    NamingConvention? namingConvention,
    Sorting? sorting,
  }) {
    return RebellionOptions(
      allCapsRuleEnabled: allCapsRuleEnabled ?? this.allCapsRuleEnabled,
      stringTypeRuleEnabled:
          stringTypeRuleEnabled ?? this.stringTypeRuleEnabled,
      atKeyTypeRuleEnabled: atKeyTypeRuleEnabled ?? this.atKeyTypeRuleEnabled,
      duplicatedKeysRuleEnabled:
          duplicatedKeysRuleEnabled ?? this.duplicatedKeysRuleEnabled,
      emptyAtKeyRuleEnabled:
          emptyAtKeyRuleEnabled ?? this.emptyAtKeyRuleEnabled,
      localeDefinitionRuleEnabled:
          localeDefinitionRuleEnabled ?? this.localeDefinitionRuleEnabled,
      mandatoryAtKeyDescriptionRuleEnabled:
          mandatoryAtKeyDescriptionRuleEnabled ??
              this.mandatoryAtKeyDescriptionRuleEnabled,
      missingPlaceholdersRuleEnabled:
          missingPlaceholdersRuleEnabled ?? this.missingPlaceholdersRuleEnabled,
      missingPluralsRuleEnabled:
          missingPluralsRuleEnabled ?? this.missingPluralsRuleEnabled,
      missingTranslationsRuleEnabled:
          missingTranslationsRuleEnabled ?? this.missingTranslationsRuleEnabled,
      namingConventionRuleEnabled:
          namingConventionRuleEnabled ?? this.namingConventionRuleEnabled,
      redundantAtKeyRuleEnabled:
          redundantAtKeyRuleEnabled ?? this.redundantAtKeyRuleEnabled,
      redundantTranslationsRuleEnabled: redundantTranslationsRuleEnabled ??
          this.redundantTranslationsRuleEnabled,
      unusedAtKeyRuleEnabled:
          unusedAtKeyRuleEnabled ?? this.unusedAtKeyRuleEnabled,
      mainLocale: mainLocale ?? this.mainLocale,
      namingConvention: namingConvention ?? this.namingConvention,
      sorting: sorting ?? this.sorting,
    );
  }
}
