import 'package:collection/collection.dart';
import 'package:rebellion/src/analyze/analyzer_options.dart';
import 'package:rebellion/src/analyze/rules/all_caps.dart';
import 'package:rebellion/src/analyze/rules/at_key_type.dart';
import 'package:rebellion/src/analyze/rules/duplicate_keys.dart';
import 'package:rebellion/src/analyze/rules/empty_at_key.dart';
import 'package:rebellion/src/analyze/rules/locale_definition_allowlist.dart';
import 'package:rebellion/src/analyze/rules/locale_definition_match.dart';
import 'package:rebellion/src/analyze/rules/locale_definition_presence.dart';
import 'package:rebellion/src/analyze/rules/mandatory_key_description.dart';
import 'package:rebellion/src/analyze/rules/missing_placeholders.dart';
import 'package:rebellion/src/analyze/rules/missing_plurals.dart';
import 'package:rebellion/src/analyze/rules/missing_translations.dart';
import 'package:rebellion/src/analyze/rules/naming_convention.dart';
import 'package:rebellion/src/analyze/rules/redundant_at_key.dart';
import 'package:rebellion/src/analyze/rules/redundant_translations.dart';
import 'package:rebellion/src/analyze/rules/sanity_check.dart';
import 'package:rebellion/src/analyze/rules/string_type.dart';
import 'package:rebellion/src/analyze/rules/unused_at_key.dart';
import 'package:rebellion/src/utils/arb_parser/parsed_arb_file.dart';

/// Simple flag-like rule that can be enabled or disabled
abstract class Rule {
  /// Default constructor
  const Rule();

  /// Check [files] and return number of found issues
  int run(List<ParsedArbFile> files, AnalyzerOptions options);
}

/// Enum of all available rules
enum RuleKey {
  /// Perform some checks to ensure data is parsed correctly
  sanityCheck('sanityCheck', true),

  /// Check that all keys are in all caps
  allCaps('all_caps', true),

  /// Check that all values are strings
  stringType('string_type', true),

  /// Check that all keys start with @
  atKeyType('at_key_type', true),

  /// Check for duplicated keys
  duplicatedKeys('duplicated_keys', true),

  /// Check for empty @-keys
  emptyAtKey('empty_at_key', true),

  /// Check that all files have a locale definition
  localeDefinitionPresent('locale_definition_presence', true),

  /// Check that the locale in the filename and in the @@locale key can be
  /// recognized by intl
  localeDefinitionAllowList('locale_definition_allowlist', true),

  /// Check that the locale in the filename and in the @@locale key match
  localeDefinitionMatch('locale_definition_match', true),

  /// Check that all @-keys have a description
  mandatoryAtKeyDescription('mandatory_at_key_description', false),

  /// Check for missing placeholders
  missingPlaceholders('missing_placeholders', true),

  /// Check for missing plurals
  missingPlurals('missing_plurals', true),

  /// Check for missing translations
  missingTranslations('missing_translations', true),

  /// Check for redundant @-keys
  redundantAtKey('redundant_at_key', true),

  /// Check for redundant translations
  redundantTranslations('redundant_translations', true),

  /// Check for unused @-keys
  unusedAtKey('unused_at_key', true),

  /// Check that keys are camelCase or snake_case
  namingConvention('naming_convention', true);

  /// Key that represents the rule. Used in YAML configuration file and when
  /// enabling/disabling rules in ARB files
  final String key;

  /// Whether the rule is enabled by default
  final bool isEnabledByDefault;

  /// Default constructor
  const RuleKey(this.key, this.isEnabledByDefault);

  /// Get [Rule] instance corresponding to this [RuleKey]
  Rule get rule {
    return switch (this) {
      RuleKey.sanityCheck => SanityCheck(),
      RuleKey.allCaps => AllCaps(),
      RuleKey.stringType => StringType(),
      RuleKey.atKeyType => AtKeyType(),
      RuleKey.duplicatedKeys => DuplicatedKeys(),
      RuleKey.emptyAtKey => EmptyAtKeys(),
      RuleKey.localeDefinitionPresent => LocaleDefinitionPresence(),
      RuleKey.localeDefinitionAllowList => LocaleDefinitionAllowlist(),
      RuleKey.localeDefinitionMatch => LocaleDefinitionMatch(),
      RuleKey.mandatoryAtKeyDescription => MandatoryKeyDescription(),
      RuleKey.missingPlaceholders => MissingPlaceholders(),
      RuleKey.missingPlurals => MissingPlurals(),
      RuleKey.missingTranslations => MissingTranslations(),
      RuleKey.redundantAtKey => RedundantAtKey(),
      RuleKey.redundantTranslations => RedundantTranslations(),
      RuleKey.unusedAtKey => UnusedAtKey(),
      RuleKey.namingConvention => NamingConventionRule(),
    };
  }

  /// Get [RuleKey] from [key] string
  static RuleKey? fromKey(String key) =>
      RuleKey.values.firstWhereOrNull((e) => e.key == key);

  /// Get all rules that are enabled by default
  static Set<RuleKey> get defaultRules =>
      RuleKey.values.where((e) => e.isEnabledByDefault).toSet();
}
