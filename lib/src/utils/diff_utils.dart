import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:rebellion/src/utils/arb_parser/parsed_arb_file.dart';
import 'package:rebellion/src/utils/extensions.dart';
import 'package:rebellion/src/utils/logger.dart';
import 'package:rebellion/src/utils/exit_exception.dart';

class DiffArbFile with EquatableMixin {
  final ParsedArbFile sourceFile;
  final List<String> untranslatedKeys;

  const DiffArbFile({
    required this.sourceFile,
    required this.untranslatedKeys,
  });

  // coverage:ignore-start
  @override
  List<Object?> get props => [sourceFile, untranslatedKeys];
  // coverage:ignore-end
}

List<DiffArbFile> getMissingTranslations(List<ParsedArbFile> files) {
  final mainFile = files.firstWhereOrNull((file) => file.file.isMainFile);
  if (mainFile == null) {
    logError("No main file found");
    throw ExitException();
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
