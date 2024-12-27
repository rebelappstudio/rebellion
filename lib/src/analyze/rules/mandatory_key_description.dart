import 'package:rebellion/src/analyze/analyzer_options.dart';
import 'package:rebellion/src/analyze/rules/rule.dart';
import 'package:rebellion/src/utils/arb_parser/at_key_meta.dart';
import 'package:rebellion/src/utils/arb_parser/parsed_arb_file.dart';
import 'package:rebellion/src/utils/extensions.dart';
import 'package:rebellion/src/utils/logger.dart';

/// Check that each @-key has a description, e.g.
/// `"@homePageTitle": {"description": "This is a title"}`
///
/// This check is off by default
class MandatoryKeyDescription extends Rule {
  /// Default constructor
  const MandatoryKeyDescription();

  @override
  int run(List<ParsedArbFile> files, AnalyzerOptions options) {
    int issues = 0;

    for (final file in files) {
      // Only check main files
      if (!file.file.isMainFile) continue;

      final keys = file.keys;
      for (final key in keys) {
        if (!key.isAtKey) continue;

        final value = file.content[key];
        if (value is AtKeyMeta && (value.description?.isEmpty ?? true)) {
          issues++;
          logError(
            '${file.file.filepath}: @-key "$key" must have a description',
          );
        }
      }
    }

    return issues;
  }
}
