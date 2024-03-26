import 'package:rebellion/utils/logger.dart';
import 'package:rebellion/utils/file_utils.dart';

final _camelCaseRe = RegExp(r'^[a-z]+((\d)|([A-Z0-9][a-z0-9]+))*([A-Z])?$');
final _snakeCaseRe = RegExp(r'^[a-z]+((\d)|(_[a-z0-9]+))*(_)?$');

enum NamingConvention {
  camel('camel', 'came case'),
  snake('snake', 'snake case');

  final String optionName;
  final String englishName;

  const NamingConvention(this.optionName, this.englishName);

  static NamingConvention fromOptionName(String optionName) {
    return NamingConvention.values
        .firstWhere((e) => e.optionName == optionName);
  }

  bool hasMatch(String input) {
    return switch (this) {
      NamingConvention.camel => _camelCaseRe.hasMatch(input),
      NamingConvention.snake => _snakeCaseRe.hasMatch(input),
    };
  }
}

bool checkKeyNamingConvention(
  List<ParsedArbFile> files,
  NamingConvention convention,
) {
  bool passed = true;

  for (final file in files) {
    for (final key in file.keys) {
      if (!convention.hasMatch(key)) {
        passed = false;
        logError(
          '${file.file.filepath}: key "$key" does not match selected naming convention (${convention.englishName})',
        );
      }
    }
  }

  return passed;
}
