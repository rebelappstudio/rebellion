import 'package:rebellion/src/analyze/rules/rule.dart';
import 'package:rebellion/src/utils/arb_parser/at_key_meta.dart';
import 'package:rebellion/src/utils/arb_parser/parsed_arb_file.dart';
import 'package:rebellion/src/utils/extensions.dart';
import 'package:rebellion/src/utils/logger.dart';
import 'package:rebellion/src/utils/rebellion_options.dart';

/// Check that @-key is a valid JSON object, e.g.
/// "@homePageTitle": {"description": "This is a title"}
///
/// Fails in cases like this:
/// * "@homePageTitle": null,
/// * "@homePageTitle": "not a JSON object",
class AtKeyType extends Rule {
  /// Default constructor
  const AtKeyType();

  @override
  int run(List<ParsedArbFile> files, RebellionOptions options) {
    int issues = 0;

    for (final file in files) {
      final keys = file.keys;
      for (final key in keys) {
        if (!key.isAtKey) continue;

        final value = file.content[key];
        if (value is! AtKeyMeta) {
          issues++;
          logError(
            '${file.file.filepath}: @-key "$key" must be a JSON object. Instead "${value.runtimeType}" was found',
          );
        }
      }
    }

    return issues;
  }
}
