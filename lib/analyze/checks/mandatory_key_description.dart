import 'package:rebellion/analyze/checks/check_base.dart';
import 'package:rebellion/icu_parser/icu_parser.dart';
import 'package:rebellion/utils/extensions.dart';
import 'package:rebellion/utils/logger.dart';
import 'package:rebellion/utils/file_utils.dart';

/// Check that each @-key has a description, e.g.
/// `"@homePageTitle": {"description": "This is a title"}`
///
/// This check is off by default
class MandatoryKeyDescription extends CheckBase {
  const MandatoryKeyDescription()
      : super(
          optionName: 'mandatory-at-key-description',
          defaultsTo: false,
        );

  @override
  int run(IcuParser parser, List<ParsedArbFile> files) {
    int issues = 0;

    for (final file in files) {
      final keys = file.keys;
      for (final key in keys) {
        if (!key.isAtKey) continue;

        final value = file.content[key];
        if (value is Map && !value.containsKey('description')) {
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
