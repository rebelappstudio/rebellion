import 'package:rebellion/utils/extensions.dart';
import 'package:rebellion/utils/logger.dart';
import 'package:rebellion/utils/file_utils.dart';

bool checkUnusedAtKey(List<ParsedArbFile> files) {
  bool passed = true;

  for (final file in files) {
    final keys = file.keys;
    for (final key in keys) {
      if (!key.isAtKey) continue;

      final correspondingKey = key.atKeyToRegularKey;
      if (!keys.contains(correspondingKey)) {
        passed = false;
        logError(
          '${file.file.filepath}: @-key "$key" without corresponding key "$correspondingKey"',
        );
      }
    }
  }

  return passed;
}
