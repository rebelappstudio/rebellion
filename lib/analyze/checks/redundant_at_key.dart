import 'package:rebellion/analyze/checks/check_base.dart';
import 'package:rebellion/icu_parser/icu_parser.dart';
import 'package:rebellion/utils/extensions.dart';
import 'package:rebellion/utils/logger.dart';
import 'package:rebellion/utils/file_utils.dart';

/// Translation files contain @-keys with data already present in the main file
class RedundantAtKey extends CheckBase {
  const RedundantAtKey()
      : super(
          optionName: 'redundant-at-key',
          defaultsTo: true,
        );

  @override
  int run(IcuParser parser, List<ParsedArbFile> files) {
    var issues = 0;

    for (final file in files) {
      if (file.file.isMainFile) continue;

      for (final key in file.keys) {
        if (!key.isAtKey) continue;

        issues++;
        logError(
          '${file.file.filepath}: @-key "$key" should only be present in the main file',
        );
      }
    }

    return issues;
  }
}
