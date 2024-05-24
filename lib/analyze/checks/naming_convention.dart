import 'package:collection/collection.dart';
import 'package:rebellion/analyze/checks/check_base.dart';
import 'package:rebellion/icu_parser/icu_parser.dart';
import 'package:rebellion/utils/file_utils.dart';
import 'package:rebellion/utils/logger.dart';

final _camelCaseRe = RegExp(r'^[a-z]+((\d)|([A-Z0-9][a-z0-9]+))*([A-Z])?$');
final _snakeCaseRe = RegExp(r'^[a-z]+((\d)|(_[a-z0-9]+))*(_)?$');

enum NamingConvention {
  camel('camel', 'came case'),
  snake('snake', 'snake case');

  final String optionName;
  final String englishName;

  const NamingConvention(this.optionName, this.englishName);

  static NamingConvention? fromOptionName(String? optionName) {
    return NamingConvention.values
        .firstWhereOrNull((e) => e.optionName == optionName);
  }

  bool hasMatch(String input) {
    return switch (this) {
      NamingConvention.camel => _camelCaseRe.hasMatch(input),
      NamingConvention.snake => _snakeCaseRe.hasMatch(input),
    };
  }
}

/// Check that keys are camelCase or snake_case. In addition this checks that
/// keys use latin characters only
class NamingConventionCheck extends CheckBase {
  const NamingConventionCheck();

  @override
  int run(
    IcuParser parser,
    List<ParsedArbFile> files,
    RebellionOptions options,
  ) {
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
