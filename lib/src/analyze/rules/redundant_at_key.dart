import 'package:rebellion/src/analyze/analyzer_options.dart';
import 'package:rebellion/src/analyze/rules/rule.dart';
import 'package:rebellion/src/utils/arb_parser/at_key_meta.dart';
import 'package:rebellion/src/utils/arb_parser/parsed_arb_file.dart';
import 'package:rebellion/src/utils/extensions.dart';
import 'package:rebellion/src/utils/logger.dart';

/// Translation files contain @-keys with data already present in the main file
class RedundantAtKey extends Rule {
  /// Default constructor
  const RedundantAtKey();

  @override
  int run(List<ParsedArbFile> files, AnalyzerOptions options) {
    var issues = 0;

    for (final file in files) {
      if (file.file.isMainFile) continue;

      for (final key in file.keys) {
        if (!key.isAtKey) continue;

        final atKey = file.content[key.toAtKey];
        if (atKey is AtKeyMeta && atKey.isRuleIgnored(RuleKey.redundantAtKey)) {
          continue;
        }

        issues++;
        logError(
          '${file.file.filepath}: @-key "$key" should only be present in the main file',
        );
      }
    }

    return issues;
  }
}
