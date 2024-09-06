import 'package:rebellion/src/analyze/checks/check_base.dart';
import 'package:rebellion/src/utils/arb_parser/at_key_meta.dart';
import 'package:rebellion/src/utils/arb_parser/parsed_arb_file.dart';
import 'package:rebellion/src/utils/extensions.dart';
import 'package:rebellion/src/utils/logger.dart';
import 'package:rebellion/src/utils/rebellion_options.dart';

/// Check that there are no @-keys without content
class EmptyAtKeys extends CheckBase {
  const EmptyAtKeys();

  @override
  int run(List<ParsedArbFile> files, RebellionOptions options) {
    int issues = 0;

    for (final file in files) {
      final keys = file.keys;
      for (final key in keys) {
        if (!key.isAtKey) continue;

        final value = file.content[key];
        if (value is AtKeyMeta) {
          if ((value.description?.isEmpty ?? true) &&
              value.placeholders.isEmpty) {
            issues++;
            logError('${file.file.filepath}: empty @-key "$key"');
          }
        }
      }
    }

    return issues;
  }
}
