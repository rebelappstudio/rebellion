import 'package:args/args.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:rebellion/src/analyze/rules/naming_convention.dart';
import 'package:rebellion/src/analyze/rules/rule.dart';
import 'package:rebellion/src/sort/sort.dart';
import 'package:rebellion/src/utils/args.dart';
import 'package:rebellion/src/utils/file_reader.dart';
import 'package:yaml/yaml.dart';

/// Filename of the configuration YAML file
@visibleForTesting
const configFilename = 'rebellion_options.yaml';

/// Options for the rebellion tool. This includes enabled rules, main locale,
/// naming convention and sorting of keys.
///
/// This class represents the YAML configuration file and CLI arguments.
class RebellionOptions with EquatableMixin {
  /// List of enabled rules
  final Set<RuleKey> enabledRules;

  /// Default locale of the project
  final String mainLocale;

  /// Naming convention for keys
  final NamingConvention namingConvention;

  /// Sorting of keys
  final Sorting sorting;

  /// Default constructor
  @visibleForTesting
  RebellionOptions({
    required Set<RuleKey>? enabledRules,
    required String? mainLocale,
    required NamingConvention? namingConvention,
    required Sorting? sorting,
  })  : enabledRules = enabledRules ?? RuleKey.defaultRules,
        mainLocale = mainLocale ?? defaultMainLocale,
        namingConvention = namingConvention ?? NamingConvention.camel,
        sorting = sorting ?? Sorting.alphabetical;

  /// Default empty constructor
  factory RebellionOptions.empty() {
    return RebellionOptions(
      enabledRules: null,
      mainLocale: null,
      namingConvention: null,
      sorting: null,
    );
  }

  /// Create an instance of [RebellionOptions] from CLI arguments
  factory RebellionOptions.fromCliArguments(ArgResults? argResults) {
    return RebellionOptions(
      mainLocale: argResults?.option(CliArgs.mainLocaleParam),
      enabledRules: null,
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

    final rules = yaml.nodes['rules'] as YamlList? ?? const [];
    final options = yaml.nodes['options'] as YamlMap?;

    final enabledRules = {
      // Always include sanity check as first rule
      RuleKey.sanityCheck,
      ...rules.map((key) => RuleKey.fromKey(key)).nonNulls,
    };

    return RebellionOptions(
      enabledRules: enabledRules,
      mainLocale: options?[YamlArgs.mainLocale] as String?,
      namingConvention: NamingConvention.fromOptionName(
        options?[YamlArgs.namingConvention] as String?,
      ),
      sorting: Sorting.fromOptionName(options?[YamlArgs.sorting] as String?),
    );
  }

  @override
  List<Object?> get props => [
        enabledRules,
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
    Set<RuleKey>? enabledRules,
    String? mainLocale,
    NamingConvention? namingConvention,
    Sorting? sorting,
  }) {
    return RebellionOptions(
      enabledRules: enabledRules ?? this.enabledRules,
      mainLocale: mainLocale ?? this.mainLocale,
      namingConvention: namingConvention ?? this.namingConvention,
      sorting: sorting ?? this.sorting,
    );
  }
}
