import 'package:collection/collection.dart';
import 'package:rebellion/src/analyze/rules/rule.dart';
import 'package:rebellion/src/utils/arb_parser/parsed_arb_file.dart';
import 'package:rebellion/src/utils/extensions.dart';
import 'package:rebellion/src/utils/logger.dart';
import 'package:rebellion/src/utils/rebellion_options.dart';

// Note: these regexps are quite strict and no latin extended characters are
// allowed
final _camelCaseRe = RegExp(r'^[a-z]+((\d)|([A-Z0-9][a-z0-9]+))*([A-Z])?$');
final _snakeCaseRe = RegExp(r'^[a-z]+((\d)|(_[a-z0-9]+))*(_)?$');

enum NamingConvention {
  camel('camel', 'camel case'),
  snake('snake', 'snake case');

  final String optionName;
  final String englishName;

  const NamingConvention(this.optionName, this.englishName);

  static NamingConvention? fromOptionName(String? optionName) {
    return NamingConvention.values
        .firstWhereOrNull((e) => e.optionName == optionName);
  }

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
  const NamingConventionRule();

  @override
  int run(List<ParsedArbFile> files, RebellionOptions options) {
    int issues = 0;

    final convention = options.namingConvention;
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