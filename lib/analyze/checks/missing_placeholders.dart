import 'package:rebellion/analyze/checks/check_base.dart';
import 'package:rebellion/icu_parser/icu_parser.dart';
import 'package:rebellion/utils/file_utils.dart';

/// Translation file contains @-keys without specifying the data type of the
/// placeholders
class MissingPlaceholders extends CheckBase {
  const MissingPlaceholders();

  @override
  int run(
    IcuParser parser,
    List<ParsedArbFile> files,
    RebellionOptions options,
  ) {
    // TODO placeholders but without data type
    // TODO placeholders not present in other translations
    // TODO placeholders defined but not present in the string itself
    return 0;
  }
}
