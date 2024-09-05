import 'package:collection/collection.dart';
import 'package:rebellion/src/analyze/checks/check_base.dart';
import 'package:rebellion/src/utils/arb_parser/parsed_arb_file.dart';
import 'package:rebellion/src/utils/extensions.dart';
import 'package:rebellion/src/utils/file_utils.dart';
import 'package:rebellion/src/utils/logger.dart';

/// Check if there are unnecessary translations (translation files contain
/// keys not present in the main file)
class RedundantTranslations extends CheckBase {
  const RedundantTranslations();

  @override
  int run(List<ParsedArbFile> files, RebellionOptions options) {
    var issues = 0;

    final mainFile = files.firstWhereOrNull((file) => file.file.isMainFile);
    if (mainFile == null) {
      logError("No main file found");
      return 1;
    }

    for (final file in files) {
      if (file.file.isMainFile) continue;

      final redundantKeys = file.keys.where(
        (key) =>
            !key.isLocaleDefinition &&
            !key.isAtKey &&
            !mainFile.keys.contains(key),
      );

      for (final key in redundantKeys) {
        issues++;
        logError(
          '${file.file.filepath}: redundant translation "$key"',
        );
      }
    }

    return issues;
  }
}
