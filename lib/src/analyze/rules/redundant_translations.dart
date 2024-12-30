import 'package:rebellion/src/analyze/analyzer_options.dart';
import 'package:rebellion/src/analyze/rules/rule.dart';
import 'package:rebellion/src/utils/arb_parser/parsed_arb_file.dart';
import 'package:rebellion/src/utils/extensions.dart';
import 'package:rebellion/src/utils/logger.dart';

/// Check if there are unnecessary translations (translation files contain
/// keys not present in the main file)
class RedundantTranslations extends Rule {
  /// Default constructor
  const RedundantTranslations();

  @override
  int run(List<ParsedArbFile> files, AnalyzerOptions options) {
    var issues = 0;

    // Only check if main file is available
    if (!options.containsMainFile) return issues;

    final mainFile = files.firstWhere((file) => file.file.isMainFile);
    for (final file in files) {
      if (file.file.isMainFile) continue;

      final redundantKeys = file.keys.where(
        (key) =>
            !key.isLocaleDefinition &&
            !key.isAtKey &&
            !mainFile.keys.contains(key),
      );

      for (final key in redundantKeys) {
        issues++;
        logError(
          '${file.file.filepath}: redundant translation "$key"',
        );
      }
    }

    return issues;
  }
}
