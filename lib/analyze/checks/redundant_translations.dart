import 'package:collection/collection.dart';
import 'package:rebellion/analyze/checks/check_base.dart';
import 'package:rebellion/icu_parser/icu_parser.dart';
import 'package:rebellion/utils/extensions.dart';
import 'package:rebellion/utils/logger.dart';
import 'package:rebellion/utils/file_utils.dart';

/// Check if there are unnecessary translations (translation files contain
/// keys not present in the main file)
class RedundantTranslations extends CheckBase {
  const RedundantTranslations()
      : super(
          optionName: 'redundant-translations',
          defaultsTo: true,
        );

  @override
  int run(IcuParser parser, List<ParsedArbFile> files) {
    var issues = 0;

    final mainFile = files.firstWhereOrNull((file) => file.file.isMainFile);
    if (mainFile == null) {
      logError("No main file found");
      return 1;
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
        issues++;
        logError(
          '${file.file.filepath}: redundant translations for: $redundantKeys',
        );
      }
    }

    return issues;
  }
}
