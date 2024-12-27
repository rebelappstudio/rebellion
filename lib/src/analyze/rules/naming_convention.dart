import 'package:collection/collection.dart';
import 'package:rebellion/src/analyze/analyzer_options.dart';
import 'package:rebellion/src/analyze/rules/rule.dart';
import 'package:rebellion/src/utils/arb_parser/parsed_arb_file.dart';
import 'package:rebellion/src/utils/extensions.dart';
import 'package:rebellion/src/utils/logger.dart';

// Note: these regexps are quite strict and no latin extended characters are
// allowed
final _camelCaseRe = RegExp(r'^[a-z]+((\d)|([A-Z0-9][a-z0-9]+))*([A-Z])?$');
final _snakeCaseRe = RegExp(r'^[a-z]+((\d)|(_[a-z0-9]+))*(_)?$');

/// Naming convention for keys
enum NamingConvention {
  /// Camel case naming convention, e.g. "homePageTitle"
  camel('camel', 'camel case'),

  /// Snake case naming convention, e.g. "home_page_title"
  snake('snake', 'snake case');

  /// CLI option name
  final String optionName;

  /// Human-readable name
  final String englishName;

  const NamingConvention(this.optionName, this.englishName);

  /// Returns the naming convention from the CLI option name
  static NamingConvention? fromOptionName(String? optionName) {
    return NamingConvention.values
        .firstWhereOrNull((e) => e.optionName == optionName);
  }

  /// Returns true if [input] matches the naming convention
  bool hasMatch(String input) {
    final String clean = input.cleanKey;
    return switch (this) {
      NamingConvention.camel => _camelCaseRe.hasMatch(clean),
      NamingConvention.snake => _snakeCaseRe.hasMatch(clean),
    };
  }
}

/// Check that keys are camelCase or snake_case. In addition this checks that
/// keys use latin characters only
class NamingConventionRule extends Rule {
  /// Default constructor
  const NamingConventionRule();

  @override
  int run(List<ParsedArbFile> files, AnalyzerOptions options) {
    int issues = 0;

    final convention = options.rebellionOptions.namingConvention;
    for (final file in files) {
      for (final key in file.keys) {
        if (convention.hasMatch(key) == false) {
          issues++;
          logError(
            '${file.file.filepath}: key "$key" does not match selected naming convention (${convention.englishName})',
          );
        }
      }
    }

    return issues;
  }
}
