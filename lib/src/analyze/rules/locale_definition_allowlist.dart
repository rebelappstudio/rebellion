import 'package:rebellion/src/analyze/analyzer_options.dart';
import 'package:rebellion/src/analyze/rules/rule.dart';
import 'package:rebellion/src/utils/arb_parser/parsed_arb_file.dart';
import 'package:rebellion/src/utils/locales.dart';
import 'package:rebellion/src/utils/logger.dart';

/// Check if the locale in the filename and in the @@locale key can be
/// recognized by intl
class LocaleDefinitionAllowlist extends Rule {
  @override
  int run(List<ParsedArbFile> files, AnalyzerOptions options) {
    int issues = 0;

    for (final file in files) {
      final filenameLocale = file.file.locale.toLowerCase();
      final contentLocale = file.content['@@locale']?.toLowerCase();

      if (!localesAllowlist.contains(filenameLocale)) {
        issues++;
        logError(
          '${file.file.filepath}: filename locale "$filenameLocale" is not in the allowlist',
        );
      }

      if (contentLocale != null && !localesAllowlist.contains(contentLocale)) {
        issues++;
        logError(
          '${file.file.filepath}: @@locale value "$contentLocale" is not in the allowlist',
        );
      }
    }

    return issues;
  }
}
