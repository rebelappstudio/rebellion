import 'package:rebellion/analyze/checks/check_base.dart';
import 'package:rebellion/icu_parser/icu_parser_extensions.dart';
import 'package:rebellion/utils/extensions.dart';
import 'package:rebellion/utils/logger.dart';
import 'package:rebellion/icu_parser/icu_parser.dart';
import 'package:rebellion/icu_parser/message_format.dart';
import 'package:rebellion/utils/file_utils.dart';
import 'package:rebellion/utils/plurals.dart';

/// Check if there are missing plurals in main file and translations
class MissingPlurals extends CheckBase {
  const MissingPlurals();

  @override
  int run(
    IcuParser parser,
    List<ParsedArbFile> files,
    RebellionOptions options,
  ) {
    int issues = 0;

    // TODO check if gender, select and plurals can be parsed by intl
    // TODO check plural placeholder (one, =1 etc)
    // TODO check redundant plurals for this language

    for (final file in files) {
      for (final key in file.keys) {
        if (key.isAtKey) continue;
        if (key.isLocaleDefinition) continue;

        final value = file.content[key];
        parser.likelyContainsPlural(value);

        continue;
        final parseResult = parser.parse(value);

        if (parseResult is List<LiteralElement>) {
          // TODO probably an error
        }

        print('foo $parseResult');
        if (parseResult is PluralElement) {
          final options =
              (parseResult as PluralElement).options.map((e) => e.name);
          final requiredValue = requiredPlurals(file.file.locale);
          final missingPlurals =
              requiredValue.where((e) => !options.contains(e));
          final notAllowedPlurals =
              options.where((e) => !allPossiblePlurals.contains(e));

          // TODO check if it's plurals but not parsed as plurals. It means intl won't be able to parse it as plural

          if (missingPlurals.isNotEmpty) {
            issues++;
            logError(
              '${file.file.filepath}: missing plurals for: ${missingPlurals.join(', ')}',
            );
          }

          if (notAllowedPlurals.isNotEmpty) {
            issues++;
            logError(
              '${file.file.filepath}: keys are not allowed: ${notAllowedPlurals.join(', ')}',
            );
          }
        }
      }
    }

    return issues;
  }
}
