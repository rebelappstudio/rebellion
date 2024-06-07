import 'package:rebellion/analyze/checks/check_base.dart';
import 'package:rebellion/icu_parser/icu_parser.dart';
import 'package:rebellion/utils/extensions.dart';
import 'package:rebellion/utils/logger.dart';
import 'package:rebellion/utils/file_utils.dart';

/// Check that @-key is a valid JSON object, e.g.
/// "@homePageTitle": {"description": "This is a title"}
///
/// Fails in cases like this:
/// * "@homePageTitle": null,
/// * "@homePageTitle": "not a JSON object",
class AtKeyType extends CheckBase {
  const AtKeyType();

  @override
  int run(
    IcuParser parser,
    List<ParsedArbFile> files,
    RebellionOptions options,
  ) {
    int issues = 0;

    for (final file in files) {
      final keys = file.keys;
      for (final key in keys) {
        if (!key.isAtKey) continue;

        final value = file.content[key];
        if (value is! Map) {
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
