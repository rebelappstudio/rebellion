import 'package:rebellion/src/analyze/rules/rule.dart';
import 'package:rebellion/src/utils/arb_parser/parsed_arb_file.dart';
import 'package:rebellion/src/utils/extensions.dart';
import 'package:rebellion/src/utils/logger.dart';
import 'package:rebellion/src/utils/rebellion_options.dart';

/// Checks that all strings are of type String.
///
/// Catches cases like this:
/// * "key": 1
/// * "key": true
/// * "key": null
/// * "key": {}
class StringType extends Rule {
  const StringType();

  @override
  int run(List<ParsedArbFile> files, RebellionOptions options) {
    int issues = 0;

    for (final file in files) {
      final keys = file.keys;

      for (final key in keys) {
        if (key.isAtKey || key.isLocaleDefinition) continue;

        final value = file.content[key];
        if (value is! String) {
          issues++;
          logError(
            '${file.file.filepath}: "$key" must be a string. Instead "${value.runtimeType}" was found',
          );
        }
      }
    }

    return issues;
  }
}
