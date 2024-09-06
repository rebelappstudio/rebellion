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

  List<dynamic> get atKeys =>
      content.keys.where((key) => key.startsWith('@')).toList();

  ParsedArbFile copyWith({Map<String, dynamic>? content}) {
    return ParsedArbFile(
      file: file,
      content: content ?? this.content,
      rawKeys: rawKeys,
    );
  }

  @override
  List<Object?> get props => [file, content, rawKeys];
}
