import 'package:rebellion/src/analyze/checks/check_base.dart';
import 'package:rebellion/src/utils/arb_parser/parsed_arb_file.dart';
import 'package:rebellion/src/utils/extensions.dart';
import 'package:rebellion/src/utils/logger.dart';
import 'package:rebellion/src/utils/rebellion_options.dart';

/// Translation files contain @-keys with data already present in the main file
class RedundantAtKey extends CheckBase {
  const RedundantAtKey();

  @override
  int run(List<ParsedArbFile> files, RebellionOptions options) {
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
