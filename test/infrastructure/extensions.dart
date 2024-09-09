import 'package:rebellion/src/analyze/rules/naming_convention.dart';
import 'package:rebellion/src/sort/sort.dart';
import 'package:rebellion/src/utils/rebellion_options.dart';

extension RebellionOptionsX on RebellionOptions {
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
