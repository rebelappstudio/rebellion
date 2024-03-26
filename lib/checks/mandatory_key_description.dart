import 'package:rebellion/utils/extensions.dart';
import 'package:rebellion/utils/logger.dart';
import 'package:rebellion/utils/file_utils.dart';

bool checkMandatoryKeyDescription(List<ParsedArbFile> files) {
  bool passed = true;

  for (final file in files) {
    final keys = file.keys;
    for (final key in keys) {
      if (!key.isAtKey) continue;

      final value = file.content[key];
      if (value is Map && !value.containsKey('description')) {
        passed = false;
        logError(
          '${file.file.filepath}: @-key "$key" must have a description',
        );
      }
    }
  }

  return passed;
}
