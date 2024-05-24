import 'package:rebellion/analyze/checks/check_base.dart';
import 'package:rebellion/icu_parser/icu_parser.dart';
import 'package:rebellion/icu_parser/message_format.dart';
import 'package:rebellion/utils/file_utils.dart';
import 'package:rebellion/utils/logger.dart';

/// Check if there are all caps strings. This considered to be a bad practice.
/// It's better to convert to all caps programmatically
class AllCaps extends CheckBase {
  const AllCaps();

  @override
  int run(
    IcuParser parser,
    List<ParsedArbFile> files,
    RebellionOptions options,
  ) {
    // TODO also check selects and plurals
    int issues = 0;

    for (final file in files) {
      final keys = file.keys;
      for (final key in keys) {
        final value = file.content[key];

        // if (value is String) {
        //   final parseResult = parser.parse(value);

        //   if (parseResult is PluralElement) {
        //     (parseResult as PluralElement)
        //         .options
        //         .any((element) => _isAllCapsString(element.value.toString()));
        //     // TODO
        //   } else {
        //     // TODO other types
        //   }
        // }

        if (value is String && _isAllCapsString(value)) {
          issues++;
          logError('${file.file.filepath}: all caps string key "$key"');
        }
      }
    }

    return issues;
  }

  bool _isAllCapsString(String value) {
    return value == value.toUpperCase();
  }
}
