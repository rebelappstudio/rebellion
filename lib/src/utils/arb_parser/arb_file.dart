import 'package:equatable/equatable.dart';

/// Represents an ARB file on disk
class ArbFile with EquatableMixin {
  /// Path to the ARB file
  final String filepath;

  /// Locale of the ARB file parsed from the filename
  final String filenameLocale;

  /// Whether the ARB file is the main file (default locale)
  final bool isMainFile;

  /// Default constructor
  const ArbFile({
    required this.filepath,
    required this.filenameLocale,
    required this.isMainFile,
  });

  // coverage:ignore-start
  @override
  List<Object?> get props => [filepath, filenameLocale, isMainFile];
  // coverage:ignore-end
}
