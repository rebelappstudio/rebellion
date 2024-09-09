import 'package:equatable/equatable.dart';
import 'package:rebellion/src/utils/arb_parser/arb_file.dart';

class ParsedArbFile with EquatableMixin {
  final ArbFile file;
  final Map<String, dynamic> content;

  /// All keys including duplicates if any
  final List<String> rawKeys;

  const ParsedArbFile({
    required this.file,
    required this.content,
    required this.rawKeys,
  });

  List<String> get keys => content.keys.toList();

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
