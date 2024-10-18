import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:rebellion/src/analyze/rules/all_caps.dart';
import 'package:rebellion/src/analyze/rules/at_key_type.dart';
import 'package:rebellion/src/analyze/rules/rule.dart';
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
import 'package:rebellion/src/analyze/rules/string_type.dart';
import 'package:rebellion/src/analyze/rules/unused_at_key.dart';
import 'package:rebellion/src/sort/sort.dart';
import 'package:rebellion/src/utils/main_locale.dart';
import 'package:yaml/yaml.dart';

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
    required this.allCapsRuleEnabled,
    required this.stringTypeRuleEnabled,
    required this.atKeyTypeRuleEnabled,
    required this.duplicatedKeysRuleEnabled,
    required this.emptyAtKeyRuleEnabled,
    required this.localeDefinitionRuleEnabled,
    required this.mandatoryAtKeyDescriptionRuleEnabled,
    required this.missingPlaceholdersRuleEnabled,
    required this.missingPluralsRuleEnabled,
    required this.missingTranslationsRuleEnabled,
    required this.namingConventionRuleEnabled,
    required this.redundantAtKeyRuleEnabled,
    required this.redundantTranslationsRuleEnabled,
    required this.unusedAtKeyRuleEnabled,
    required this.mainLocale,
    required this.namingConvention,
    required this.sorting,
  });

  /// Default empty constructor
  factory RebellionOptions.empty() {
    return RebellionOptions(
      allCapsRuleEnabled: true,
      stringTypeRuleEnabled: true,
      atKeyTypeRuleEnabled: true,
      duplicatedKeysRuleEnabled: true,
      emptyAtKeyRuleEnabled: true,
      localeDefinitionRuleEnabled: true,
      mandatoryAtKeyDescriptionRuleEnabled: false,
      missingPlaceholdersRuleEnabled: true,
      missingPluralsRuleEnabled: true,
      missingTranslationsRuleEnabled: true,
      namingConventionRuleEnabled: true,
      redundantAtKeyRuleEnabled: true,
      redundantTranslationsRuleEnabled: true,
      unusedAtKeyRuleEnabled: true,
      mainLocale: defaultMainLocale,
      namingConvention: NamingConvention.camel,
      sorting: Sorting.alphabetical,
    );
  }

  /// Create an instance of [RebellionOptions] from a YAML file content
  factory RebellionOptions.fromYaml(YamlList? rules, YamlMap? options) {
    return RebellionOptions(
      allCapsRuleEnabled: rules?.contains('all_caps') ?? false,
      stringTypeRuleEnabled: rules?.contains('string_type') ?? false,
      atKeyTypeRuleEnabled: rules?.contains('at_key_type') ?? false,
      duplicatedKeysRuleEnabled: rules?.contains('duplicated_keys') ?? false,
      emptyAtKeyRuleEnabled: rules?.contains('empty_at_key') ?? false,
      localeDefinitionRuleEnabled:
          rules?.contains('locale_definition') ?? false,
      mandatoryAtKeyDescriptionRuleEnabled:
          rules?.contains('mandatory_at_key_description') ?? false,
      missingPlaceholdersRuleEnabled:
          rules?.contains('missing_placeholders') ?? false,
      missingPluralsRuleEnabled: rules?.contains('missing_plurals') ?? false,
      missingTranslationsRuleEnabled:
          rules?.contains('missing_translations') ?? false,
      namingConventionRuleEnabled:
          rules?.contains('naming_convention') ?? false,
      redundantAtKeyRuleEnabled: rules?.contains('redundant_at_key') ?? false,
      redundantTranslationsRuleEnabled:
          rules?.contains('redundant_translations') ?? false,
      unusedAtKeyRuleEnabled: rules?.contains('unused_at_key') ?? false,
      mainLocale: options?['main_locale'] as String? ?? defaultMainLocale,
      namingConvention: NamingConvention.fromOptionName(
              options?['naming_convention'] as String?) ??
          NamingConvention.camel,
      sorting:
          Sorting.fromOptionName(options?['sorting']) ?? Sorting.alphabetical,
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
}
