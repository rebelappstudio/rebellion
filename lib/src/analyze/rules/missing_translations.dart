import 'package:rebellion/src/analyze/analyzer_options.dart';
import 'package:rebellion/src/analyze/rules/rule.dart';
import 'package:rebellion/src/utils/arb_parser/parsed_arb_file.dart';
import 'package:rebellion/src/utils/diff_utils.dart';
import 'package:rebellion/src/utils/logger.dart';

/// Check if there are missing translations (translation files miss some keys
/// present in the main file)
class MissingTranslations extends Rule {
  /// Default constructor
  const MissingTranslations();

  @override
  int run(List<ParsedArbFile> files, AnalyzerOptions options) {
    int issues = 0;

    final filesWithMissingTranslations = getMissingTranslations(files);
    for (final file in filesWithMissingTranslations) {
      for (final key in file.untranslatedKeys) {
        issues++;
        logError(
          '${file.sourceFile.file.filepath}: missing translation for key "$key"',
        );
      }
    }

    return issues;
  }
}
