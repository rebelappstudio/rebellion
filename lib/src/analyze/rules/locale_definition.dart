import 'package:rebellion/src/analyze/rules/rule.dart';
import 'package:rebellion/src/utils/arb_parser/parsed_arb_file.dart';
import 'package:rebellion/src/utils/logger.dart';
import 'package:rebellion/src/utils/rebellion_options.dart';

/// Translation file contains @@locale key with locale definition
class LocaleDefinitionPresent extends Rule {
  /// Default constructor
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
