import 'package:equatable/equatable.dart';
import 'package:rebellion/src/analyze/checks/all_caps.dart';
import 'package:rebellion/src/analyze/checks/at_key_type.dart';
import 'package:rebellion/src/analyze/checks/check_base.dart';
import 'package:rebellion/src/analyze/checks/duplicate_keys.dart';
import 'package:rebellion/src/analyze/checks/empty_at_key.dart';
import 'package:rebellion/src/analyze/checks/locale_definition.dart';
import 'package:rebellion/src/analyze/checks/mandatory_key_description.dart';
import 'package:rebellion/src/analyze/checks/missing_placeholders.dart';
import 'package:rebellion/src/analyze/checks/missing_plurals.dart';
import 'package:rebellion/src/analyze/checks/missing_translations.dart';
import 'package:rebellion/src/analyze/checks/naming_convention.dart';
import 'package:rebellion/src/analyze/checks/redundant_at_key.dart';
import 'package:rebellion/src/analyze/checks/redundant_translations.dart';
import 'package:rebellion/src/analyze/checks/string_type.dart';
import 'package:rebellion/src/analyze/checks/unused_at_key.dart';
import 'package:rebellion/src/sort/sort.dart';
import 'package:rebellion/src/utils/main_locale.dart';
import 'package:yaml/yaml.dart';

class RebellionOptions with EquatableMixin {
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

  factory RebellionOptions.empty() {
    return RebellionOptions._(
      allCapsCheckEnabled: true,
      stringTypeCheckEnabled: true,
      atKeyTypeCheckEnabled: true,
      duplicatedKeysCheckEnabled: true,
      emptyAtKeyCheckEnabled: true,
      localeDefinitionCheckEnabled: true,
      mandatoryAtKeyDescriptionCheckEnabled: false,
      missingPlaceholdersCheckEnabled: true,
      missingPluralsCheckEnabled: true,
      missingTranslationsCheckEnabled: true,
      namingConventionCheckEnabled: true,
      redundantAtKeyCheckEnabled: true,
      redundantTranslationsCheckEnabled: true,
      unusedAtKeyCheckEnabled: true,
      mainLocale: defaultMainLocale,
      namingConvention: NamingConvention.camel,
      sorting: Sorting.alphabetical,
    );
  }

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

  @override
  List<Object?> get props => [
        allCapsCheckEnabled,
        stringTypeCheckEnabled,
        atKeyTypeCheckEnabled,
        duplicatedKeysCheckEnabled,
        emptyAtKeyCheckEnabled,
        localeDefinitionCheckEnabled,
        mandatoryAtKeyDescriptionCheckEnabled,
        missingPlaceholdersCheckEnabled,
        missingPluralsCheckEnabled,
        missingTranslationsCheckEnabled,
        namingConventionCheckEnabled,
        redundantAtKeyCheckEnabled,
        redundantTranslationsCheckEnabled,
        unusedAtKeyCheckEnabled,
        mainLocale,
        namingConvention,
        sorting,
      ];

  RebellionOptions copyWith({
    bool? allCapsCheckEnabled,
    bool? stringTypeCheckEnabled,
    bool? atKeyTypeCheckEnabled,
    bool? duplicatedKeysCheckEnabled,
    bool? emptyAtKeyCheckEnabled,
    bool? localeDefinitionCheckEnabled,
    bool? mandatoryAtKeyDescriptionCheckEnabled,
    bool? missingPlaceholdersCheckEnabled,
    bool? missingPluralsCheckEnabled,
    bool? missingTranslationsCheckEnabled,
    bool? namingConventionCheckEnabled,
    bool? redundantAtKeyCheckEnabled,
    bool? redundantTranslationsCheckEnabled,
    bool? unusedAtKeyCheckEnabled,
    String? mainLocale,
    NamingConvention? namingConvention,
    Sorting? sorting,
  }) {
    return RebellionOptions._(
      allCapsCheckEnabled: allCapsCheckEnabled ?? this.allCapsCheckEnabled,
      stringTypeCheckEnabled:
          stringTypeCheckEnabled ?? this.stringTypeCheckEnabled,
      atKeyTypeCheckEnabled:
          atKeyTypeCheckEnabled ?? this.atKeyTypeCheckEnabled,
      duplicatedKeysCheckEnabled:
          duplicatedKeysCheckEnabled ?? this.duplicatedKeysCheckEnabled,
      emptyAtKeyCheckEnabled:
          emptyAtKeyCheckEnabled ?? this.emptyAtKeyCheckEnabled,
      localeDefinitionCheckEnabled:
          localeDefinitionCheckEnabled ?? this.localeDefinitionCheckEnabled,
      mandatoryAtKeyDescriptionCheckEnabled:
          mandatoryAtKeyDescriptionCheckEnabled ??
              this.mandatoryAtKeyDescriptionCheckEnabled,
      missingPlaceholdersCheckEnabled: missingPlaceholdersCheckEnabled ??
          this.missingPlaceholdersCheckEnabled,
      missingPluralsCheckEnabled:
          missingPluralsCheckEnabled ?? this.missingPluralsCheckEnabled,
      missingTranslationsCheckEnabled: missingTranslationsCheckEnabled ??
          this.missingTranslationsCheckEnabled,
      namingConventionCheckEnabled:
          namingConventionCheckEnabled ?? this.namingConventionCheckEnabled,
      redundantAtKeyCheckEnabled:
          redundantAtKeyCheckEnabled ?? this.redundantAtKeyCheckEnabled,
      redundantTranslationsCheckEnabled: redundantTranslationsCheckEnabled ??
          this.redundantTranslationsCheckEnabled,
      unusedAtKeyCheckEnabled:
          unusedAtKeyCheckEnabled ?? this.unusedAtKeyCheckEnabled,
      mainLocale: mainLocale ?? this.mainLocale,
      namingConvention: namingConvention ?? this.namingConvention,
      sorting: sorting ?? this.sorting,
    );
  }
}
