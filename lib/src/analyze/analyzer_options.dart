import 'package:equatable/equatable.dart';
import 'package:rebellion/src/utils/arb_parser/parsed_arb_file.dart';
import 'package:rebellion/src/utils/rebellion_options.dart';

/// Options for the `analyze` command
class AnalyzerOptions with EquatableMixin {
  /// Options to configure the analyzer
  final RebellionOptions rebellionOptions;

  /// Whether the analysis is being done on a single file
  final bool isSingleFile;

  /// Whether the analysis contains a main file
  final bool containsMainFile;

  /// Default constructor
  const AnalyzerOptions({
    required this.rebellionOptions,
    required this.isSingleFile,
    required this.containsMainFile,
  });

  /// Create [AnalyzerOptions] from a list of parsed ARB files
  factory AnalyzerOptions.fromFiles({
    required RebellionOptions rebellionOptions,
    required List<ParsedArbFile> files,
  }) {
    return AnalyzerOptions(
      rebellionOptions: rebellionOptions,
      isSingleFile: files.length == 1,
      containsMainFile: files.any((file) => file.file.isMainFile),
    );
  }

  // coverage:ignore-start
  @override
  List<Object?> get props => [rebellionOptions, isSingleFile, containsMainFile];
  // coverage:ignore-end
}
