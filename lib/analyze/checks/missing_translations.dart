import 'dart:io';

import 'package:collection/collection.dart';
import 'package:rebellion/analyze/checks/check_base.dart';
import 'package:rebellion/icu_parser/icu_parser.dart';
import 'package:rebellion/utils/extensions.dart';
import 'package:rebellion/utils/logger.dart';
import 'package:rebellion/utils/file_utils.dart';

/// Check if there are missing translations (translation files miss some keys
/// present in the main file)
class MissingTranslations extends CheckBase {
  const MissingTranslations()
      : super(
          optionName: 'missing-translations',
          defaultsTo: true,
        );

  @override
  int run(IcuParser parser, List<ParsedArbFile> files) {
    final filesWithMissingTranslations = getMissingTranslations(files);
    for (final file in filesWithMissingTranslations) {
      final missingItems = file.untranslatedKeys.map((e) => '"$e"').join(', ');
      logError(
        '${file.sourceFile.file.filepath}: missing translations $missingItems',
      );
    }

    return filesWithMissingTranslations.length;
  }
}

// TODO move
List<DiffArbFile> getMissingTranslations(List<ParsedArbFile> files) {
  final mainFile = files.firstWhereOrNull((file) => file.file.isMainFile);
  if (mainFile == null) {
    logError("No main file found");
    exit(1);
  }

  final result = <DiffArbFile>[];
  for (final file in files) {
    if (file.file.isMainFile) continue;

    final untranslatedKeys = mainFile.keys
        .where(
          (key) =>
              !key.isLocaleDefinition &&
              !key.isAtKey &&
              !file.keys.contains(key),
        )
        .toList();

    if (untranslatedKeys.isNotEmpty) {
      result.add(
        DiffArbFile(
          sourceFile: file,
          untranslatedKeys: untranslatedKeys,
        ),
      );
    }
  }

  return result;
}

// TODO move
class DiffArbFile {
  final ParsedArbFile sourceFile;
  final List<String> untranslatedKeys;

  const DiffArbFile({
    required this.sourceFile,
    required this.untranslatedKeys,
  });
}
