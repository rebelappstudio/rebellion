import 'package:rebellion/src/analyze/analyzer_options.dart';
import 'package:rebellion/src/analyze/rules/rule.dart';
import 'package:rebellion/src/utils/arb_parser/parsed_arb_file.dart';
import 'package:rebellion/src/utils/logger.dart';

/// Check for duplicated keys
class DuplicatedKeys extends Rule {
  /// Default constructor
  const DuplicatedKeys();

  @override
  int run(List<ParsedArbFile> files, AnalyzerOptions options) {
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
