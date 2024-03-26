import 'package:rebellion/utils/logger.dart';
import 'package:rebellion/utils/file_utils.dart';

bool checkLocaleDefinition(List<ParsedArbFile> files) {
  bool passed = true;

  for (final file in files) {
    final keys = file.keys;
    if (!keys.contains('@@locale')) {
      passed = false;
      logError('${file.file.filepath}: no @@locale key found');
    }
  }

  return passed;
}
