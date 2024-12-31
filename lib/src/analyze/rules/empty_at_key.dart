import 'package:rebellion/src/analyze/analyzer_options.dart';
import 'package:rebellion/src/analyze/rules/rule.dart';
import 'package:rebellion/src/utils/arb_parser/at_key_meta.dart';
import 'package:rebellion/src/utils/arb_parser/parsed_arb_file.dart';
import 'package:rebellion/src/utils/extensions.dart';
import 'package:rebellion/src/utils/logger.dart';

/// Check that there are no @-keys without content
class EmptyAtKeys extends Rule {
  /// Default constructor
  const EmptyAtKeys();

  @override
  int run(List<ParsedArbFile> files, AnalyzerOptions options) {
    int issues = 0;

    for (final file in files) {
      final keys = file.keys;
      for (final key in keys) {
        if (!key.isAtKey) continue;

        final value = file.content[key];
        if (value is AtKeyMeta) {
          final atKey = file.content[key.toAtKey];
          if (atKey is AtKeyMeta && atKey.isRuleIgnored(RuleKey.emptyAtKey)) {
            continue;
          }

          if ((value.description?.isEmpty ?? true) &&
              value.placeholders.isEmpty &&
              (value.ignoredRulesRaw.isEmpty)) {
            issues++;
            logError('${file.file.filepath}: empty @-key "$key"');
          }
        }
      }
    }

    return issues;
  }
}
