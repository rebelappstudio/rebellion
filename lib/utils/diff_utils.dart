import 'dart:io';

import 'package:collection/collection.dart';
import 'package:rebellion/utils/arb_parser/parsed_arb_file.dart';
import 'package:rebellion/utils/extensions.dart';
import 'package:rebellion/utils/logger.dart';

class DiffArbFile {
  final ParsedArbFile sourceFile;
  final List<String> untranslatedKeys;

  const DiffArbFile({
    required this.sourceFile,
    required this.untranslatedKeys,
  });
}

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
