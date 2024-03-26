import 'package:rebellion/utils/extensions.dart';
import 'package:rebellion/utils/logger.dart';
import 'package:rebellion/utils/file_utils.dart';

bool checkRedundantAtKey(List<ParsedArbFile> files) {
  bool passed = true;

  for (final file in files) {
    if (file.file.isMainFile) continue;

    for (final key in file.keys) {
      if (!key.isAtKey) continue;

      passed = false;
      logError(
        '${file.file.filepath}: @-key "$key" should only be present in the main file',
      );
    }
  }

  return passed;
}
