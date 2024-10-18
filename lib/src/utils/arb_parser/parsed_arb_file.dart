import 'package:equatable/equatable.dart';
import 'package:rebellion/src/utils/arb_parser/arb_file.dart';

/// Parsed ARB file content
class ParsedArbFile with EquatableMixin {
  /// ARB file
  final ArbFile file;

  /// Parsed file content
  final Map<String, dynamic> content;

  /// All keys including duplicates if any
  final List<String> rawKeys;

  /// Default constructor
  const ParsedArbFile({
    required this.file,
    required this.content,
    required this.rawKeys,
  });

  /// Get all keys excluding duplicates
  List<String> get keys => content.keys.toList();

  /// Copy with new content
  ParsedArbFile copyWithContent(Map<String, dynamic> content) {
    return ParsedArbFile(
      file: file,
      rawKeys: rawKeys,
      content: content,
    );
  }

  // coverage:ignore-start
  @override
  List<Object?> get props => [file, content, rawKeys];
  // coverage:ignore-end
}
