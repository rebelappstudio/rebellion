import 'package:rebellion/analyze/checks/check_base.dart';
import 'package:rebellion/utils/arb_parser/parsed_arb_file.dart';
import 'package:rebellion/utils/file_utils.dart';
import 'package:rebellion/utils/logger.dart';

/// Translation file contains @@locale key with locale definition
class LocaleDefinitionPresent extends CheckBase {
  const LocaleDefinitionPresent();

  @override
  int run(List<ParsedArbFile> files, RebellionOptions options) {
    int issues = 0;

    for (final file in files) {
      final keys = file.keys;
      if (!keys.contains('@@locale')) {
        issues++;
        logError('${file.file.filepath}: no @@locale key found');
      }
    }

    return issues;
  }
}
