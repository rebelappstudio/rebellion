import 'package:rebellion/analyze/checks/check_base.dart';
import 'package:rebellion/utils/arb_parser/parsed_arb_file.dart';
import 'package:rebellion/utils/file_utils.dart';
import 'package:rebellion/utils/logger.dart';

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
