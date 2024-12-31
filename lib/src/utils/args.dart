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

/// List of all available YAML options
///
/// [Rules] contains all available rule names that can be used in YAML
abstract class YamlArgs {
  /// Option to set main locale
  static const mainLocale = 'main_locale';

  /// Option to set naming convention
  static const namingConvention = 'naming_convention';

  /// Option to set sorting
  static const sorting = 'sorting';
}
