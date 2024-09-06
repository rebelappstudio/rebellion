import 'package:rebellion/src/analyze/checks/check_base.dart';
import 'package:rebellion/src/utils/arb_parser/parsed_arb_file.dart';
import 'package:rebellion/src/utils/logger.dart';
import 'package:rebellion/src/utils/rebellion_options.dart';

/// Check for duplicated keys
class DuplicatedKeys extends CheckBase {
  const DuplicatedKeys();

  @override
  int run(List<ParsedArbFile> files, RebellionOptions options) {
    int issues = 0;

    for (final file in files) {
      final uniqueKeys = file.keys.toSet();
      final allKeys = [...file.rawKeys];

      for (final uniqueKey in uniqueKeys) {
        allKeys.remove(uniqueKey);
      }

      for (final duplicate in allKeys) {
        issues++;
        logError(
          '${file.file.filepath}: file has duplicate key "$duplicate"',
        );
      }
    }

    return issues;
  }
}
