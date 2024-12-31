import 'package:rebellion/src/analyze/analyzer_options.dart';
import 'package:rebellion/src/analyze/rules/rule.dart';
import 'package:rebellion/src/utils/arb_parser/at_key_meta.dart';
import 'package:rebellion/src/utils/arb_parser/parsed_arb_file.dart';
import 'package:rebellion/src/utils/extensions.dart';
import 'package:rebellion/src/utils/logger.dart';

/// Perform some checks to ensure data is parsed correctly and all expected
/// properties and options are present
class SanityCheck extends Rule {
  @override
  int run(List<ParsedArbFile> files, AnalyzerOptions options) {
    int issues = 0;

    for (final file in files) {
      final keys = file.keys;
      for (final key in keys) {
        if (key.isAtKey) {
          final atKeyContent = file.content[key];
          if (atKeyContent is AtKeyMeta) {
            // Check misspelled and unknown ignored rule names
            final unknownIgnoredRules = atKeyContent.ignoredRulesRaw
                .where((key) => RuleKey.fromKey(key) == null);
            if (unknownIgnoredRules.isNotEmpty) {
              for (final rule in unknownIgnoredRules) {
                issues++;
                logError(
                  '${file.file.filepath}: key "$key" contains unknown ignored rule: "$rule"',
                );
              }
            }
          }
        }
      }
    }

    return issues;
  }
}
