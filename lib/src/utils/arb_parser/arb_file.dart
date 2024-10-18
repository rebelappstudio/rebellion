import 'package:equatable/equatable.dart';

/// Represents an ARB file
class ArbFile with EquatableMixin {
  /// Path to the ARB file
  final String filepath;

  /// Locale of the ARB file
  final String locale;

  /// Whether the ARB file is the main file (default locale)
  final bool isMainFile;

  /// Default constructor
  const ArbFile({
    required this.filepath,
    required this.locale,
    required this.isMainFile,
  });

  // coverage:ignore-start
  @override
  List<Object?> get props => [filepath, locale, isMainFile];
  // coverage:ignore-end
}
