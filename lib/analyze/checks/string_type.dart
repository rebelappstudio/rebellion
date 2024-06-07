import 'package:rebellion/analyze/checks/check_base.dart';
import 'package:rebellion/utils/file_utils.dart';
import 'package:rebellion/utils/logger.dart';

/// Checks that all strings are of type String.
///
/// Catches cases like this:
/// * "key": 1
/// * "key": true
/// * "key": null
/// * "key": {}
class StringType extends CheckBase {
  const StringType();

  @override
  int run(List<ParsedArbFile> files, RebellionOptions options) {
    int issues = 0;

    for (final file in files) {
      final keys = file.keys;

      for (final key in keys) {
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
