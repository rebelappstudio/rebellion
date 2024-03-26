import 'package:rebellion/utils/file_utils.dart';
import 'package:rebellion/utils/logger.dart';

bool checkAllCapsStrings(List<ParsedArbFile> files) {
  // TODO also check selects and plurals
  bool passed = true;

  for (final file in files) {
    final keys = file.keys;
    for (final key in keys) {
      final value = file.content[key];
      if (value is String && value == value.toUpperCase()) {
        passed = false;
        logError('${file.file.filepath}: all caps string key "$key"');
      }
    }
  }

  return passed;
}
