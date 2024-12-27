/// Default main locale. Some rules rely on values from the main locale file
/// If user doesn't set the main locale, this value is used
const defaultMainLocale = 'en';

/// List of all available CLI arguments
abstract class CliArgs {
  /// Main locale console parameter
  static const mainLocaleParam = 'main-locale';

  /// Main locale value example printed in the console
  static const mainLocaleCliValueHelp = 'en';

  /// Main locale help message printed in the console
  static const mainLocaleCliHelp =
      'Set the main locale. All localization files are compared to the main locale file for some of the checks';

  /// Sorting parameter
  static const sortingParam = 'sorting';
}

/// List of all available YAML arguments
abstract class YamlArgs {
  /// All caps rule name
  static const allCaps = 'all_caps';

  /// At key type rule name
  static const stringType = 'string_type';

  /// Duplicated keys rule name
  static const atKeyType = 'at_key_type';

  /// Empty at key rule name
  static const duplicatedKeys = 'duplicated_keys';

  /// Empty at key rule name
  static const emptyAtKey = 'empty_at_key';

  /// File name rule name
  static const localeDefinition = 'locale_definition';

  /// Mandatory at key description rule name
  static const mandatoryAtKeyDescription = 'mandatory_at_key_description';

  /// Mandatory at key rule name
  static const missingPlaceholders = 'missing_placeholders';

  /// Missing plurals rule name
  static const missingPlurals = 'missing_plurals';

  /// Missing translations rule name
  static const missingTranslations = 'missing_translations';

  /// Redundant at key rule name
  static const redundantAtKey = 'redundant_at_key';

  /// Redundant translations rule name
  static const redundantTranslations = 'redundant_translations';

  /// Unused at key rule name
  static const unusedAtKey = 'unused_at_key';

  /// Main locale option name
  static const mainLocale = 'main_locale';

  /// Naming convention option name
  static const namingConvention = 'naming_convention';

  /// Sorting option name
  static const sorting = 'sorting';
}
