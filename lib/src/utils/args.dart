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

  /// Sorting help message printed in the console
  static const sortingCliHelp =
      'How to order keys: alphabetical, alphabetical-reverse, or follow the main locale file';

  /// Diff output parameter
  static const outputParam = 'output';

  /// Diff output help message printed in the console
  static const outputCliHelp =
      'Where to write missing translations: console or file (*_diff.arb)';

  /// Verbose logging flag
  static const verboseParam = 'verbose';

  /// Verbose logging help message
  static const verboseCliHelp =
      'Print additional pipeline information for debugging';

  /// Positional arguments placeholder shown in command usage
  static const filesOrFoldersInvocation = '<files-or-folders>';

  /// Analyze command description
  static const analyzeDescription =
      'Analyze ARB file(s) and report issues\n\n'
      'Pass one or more ARB files or directories as arguments.';

  /// Diff command description
  static const diffDescription =
      'Find keys present in the main locale file but missing from other ARB files\n\n'
      'Pass one or more ARB files or directories as arguments.';

  /// Sort command description
  static const sortDescription =
      'Sort keys in ARB files\n\n'
      'Pass one or more ARB files or directories as arguments.';

  /// Build a command invocation line for usage output
  static String commandInvocation(String executableName, String commandName) =>
      '$executableName $commandName $filesOrFoldersInvocation';
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
