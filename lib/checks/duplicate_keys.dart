import 'package:rebellion/utils/logger.dart';
import 'package:rebellion/utils/file_utils.dart';

bool checkDuplicatedKeys(List<ParsedArbFile> files) {
  bool passed = true;

  for (final file in files) {
    final uniqueKeys = file.keys.toSet();
    final allKeys = [...file.rawKeys];

    for (final uniqueKey in uniqueKeys) {
      allKeys.remove(uniqueKey);
    }

    if (allKeys.isNotEmpty) {
      passed = false;
      final duplicatesString = allKeys.map((e) => '"$e"').join(', ');
      logError(
        '${file.file.filepath}: file has duplicate keys: $duplicatesString',
      );
    }
  }

  return passed;
}
