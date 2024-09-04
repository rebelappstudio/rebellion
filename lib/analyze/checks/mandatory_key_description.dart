import 'package:rebellion/analyze/checks/check_base.dart';
import 'package:rebellion/utils/arb_parser/at_key_meta.dart';
import 'package:rebellion/utils/arb_parser/parsed_arb_file.dart';
import 'package:rebellion/utils/extensions.dart';
import 'package:rebellion/utils/file_utils.dart';
import 'package:rebellion/utils/logger.dart';

/// Check that each @-key has a description, e.g.
/// `"@homePageTitle": {"description": "This is a title"}`
///
/// This check is off by default
class MandatoryKeyDescription extends CheckBase {
  const MandatoryKeyDescription();

  @override
  int run(List<ParsedArbFile> files, RebellionOptions options) {
    int issues = 0;

    for (final file in files) {
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
