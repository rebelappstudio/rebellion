import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:rebellion/src/utils/arb_parser/parsed_arb_file.dart';
import 'package:rebellion/src/utils/extensions.dart';

/// A class that represents a diff between two ARB files
class DiffArbFile with EquatableMixin {
  /// The source ARB file
  final ParsedArbFile sourceFile;

  /// The list of untranslated keys
  final List<String> untranslatedKeys;

  /// Default constructor
  const DiffArbFile({
    required this.sourceFile,
    required this.untranslatedKeys,
  });

  // coverage:ignore-start
  @override
  List<Object?> get props => [sourceFile, untranslatedKeys];
  // coverage:ignore-end
}

/// Get a list of missing translations
///
/// [files] must contain a main file (used to compare all other files against)
List<DiffArbFile> getMissingTranslations(List<ParsedArbFile> files) {
  final mainFile = files.firstWhereOrNull((file) => file.file.isMainFile);
  if (mainFile == null) {
    // No main file found to compare against
    return const [];
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
