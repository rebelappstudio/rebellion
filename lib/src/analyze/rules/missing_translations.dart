import 'package:rebellion/src/analyze/rules/rule.dart';
import 'package:rebellion/src/utils/arb_parser/parsed_arb_file.dart';
import 'package:rebellion/src/utils/diff_utils.dart';
import 'package:rebellion/src/utils/logger.dart';
import 'package:rebellion/src/utils/rebellion_options.dart';

/// Check if there are missing translations (translation files miss some keys
/// present in the main file)
class MissingTranslations extends Rule {
  const MissingTranslations();

  @override
  int run(List<ParsedArbFile> files, RebellionOptions options) {
    final filesWithMissingTranslations = getMissingTranslations(files);
    for (final file in filesWithMissingTranslations) {
      final missingItems = file.untranslatedKeys.map((e) => '"$e"').join(', ');
      logError(
        '${file.sourceFile.file.filepath}: missing translations $missingItems',
      );
    }

    return filesWithMissingTranslations.length;
  }
}
