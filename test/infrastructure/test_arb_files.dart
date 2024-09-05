import 'package:rebellion/src/utils/arb_parser/arb_file.dart';
import 'package:rebellion/src/utils/arb_parser/parsed_arb_file.dart';

/// Creates a list of [ParsedArbFile] with just one file containing a single key
List<ParsedArbFile> oneKeyFile(String string) {
  return [
    createFile(
      values: {'key': string},
    ),
  ];
}

ParsedArbFile createFile({
  required Map<String, dynamic> values,
  String filepath = 'filepath',
  String locale = 'en',
  bool isMainFile = true,
}) {
  return ParsedArbFile(
    file: ArbFile(
      filepath: filepath,
      locale: locale,
      isMainFile: isMainFile,
    ),
    content: values,
    rawKeys: values.keys.toList(),
  );
}
