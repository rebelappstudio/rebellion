import 'package:rebellion/analyze/checks/check_base.dart';
import 'package:rebellion/utils/arb_parser/parsed_arb_file.dart';
import 'package:rebellion/utils/extensions.dart';
import 'package:rebellion/utils/file_utils.dart';
import 'package:rebellion/utils/logger.dart';

/// Check if there are @-keys without corresponding key
class UnusedAtKey extends CheckBase {
  const UnusedAtKey();

  @override
  int run(List<ParsedArbFile> files, RebellionOptions options) {
    var issues = 0;

    for (final file in files) {
      final keys = file.keys;
      for (final key in keys) {
        if (!key.isAtKey) continue;

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
