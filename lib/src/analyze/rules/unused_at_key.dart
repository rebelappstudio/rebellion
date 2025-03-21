import 'package:rebellion/src/analyze/analyzer_options.dart';
import 'package:rebellion/src/analyze/rules/rule.dart';
import 'package:rebellion/src/utils/arb_parser/at_key_meta.dart';
import 'package:rebellion/src/utils/arb_parser/parsed_arb_file.dart';
import 'package:rebellion/src/utils/extensions.dart';
import 'package:rebellion/src/utils/logger.dart';

/// Check if there are @-keys without corresponding key
class UnusedAtKey extends Rule {
  /// Default constructor
  const UnusedAtKey();

  @override
  int run(List<ParsedArbFile> files, AnalyzerOptions options) {
    var issues = 0;

    for (final file in files) {
      final keys = file.keys;
      for (final key in keys) {
        if (!key.isAtKey) continue;

        final atKey = file.content[key.toAtKey];
        if (atKey is AtKeyMeta && atKey.isRuleIgnored(RuleKey.unusedAtKey)) {
          continue;
        }

        final correspondingKey = key.atKeyToRegularKey;
        if (!keys.contains(correspondingKey)) {
          issues++;
          logError(
            '${file.file.filepath}: @-key "$key" without corresponding key "$correspondingKey"',
          );
        }
      }
    }

    return issues;
  }
}
