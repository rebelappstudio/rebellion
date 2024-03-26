import 'package:collection/collection.dart';
import 'package:rebellion/utils/extensions.dart';
import 'package:rebellion/utils/logger.dart';
import 'package:rebellion/utils/file_utils.dart';

bool checkRedundantTranslations(List<ParsedArbFile> files) {
  bool passed = true;

  final mainFile = files.firstWhereOrNull((file) => file.file.isMainFile);
  if (mainFile == null) {
    logError("No main file found");
    return false;
  }

  for (final file in files) {
    if (file.file.isMainFile) continue;

    final redundantKeys = file.keys
        .where(
          (key) =>
              !key.isLocaleDefinition &&
              !key.isAtKey &&
              !mainFile.keys.contains(key),
        )
        .map((e) => '"$e"')
        .join(', ');
    if (redundantKeys.isNotEmpty) {
      passed = false;
      logError(
        '${file.file.filepath}: redundant translations for: $redundantKeys',
      );
    }
  }

  return passed;
}
