import 'package:rebellion/utils/extensions.dart';
import 'package:rebellion/utils/logger.dart';
import 'package:rebellion/parser/icu_parser.dart';
import 'package:rebellion/parser/message_format.dart';
import 'package:rebellion/utils/file_utils.dart';
import 'package:rebellion/utils/plurals.dart';

bool checkMissingPlurals(List<ParsedArbFile> files) {
  bool passed = true;

  // TODO check if gender, select and plurals can be parsed by intl
  // TODO check plural placeholder (one, =1 etc)
  // TODO check redundant plurals for this language

  final parser = IcuParser();
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
        final missingPlurals = requiredValue.where((e) => !options.contains(e));
        final notAllowedPlurals =
            options.where((e) => !allPossiblePlurals.contains(e));

        // TODO check if it's plurals but not parsed as plurals. It means intl won't be able to parse it as plural

        if (missingPlurals.isNotEmpty) {
          passed = false;
          logError(
            '${file.file.filepath}: missing plurals for: ${missingPlurals.join(', ')}',
          );
        }

        if (notAllowedPlurals.isNotEmpty) {
          passed = false;
          logError(
            '${file.file.filepath}: keys are not allowed: ${notAllowedPlurals.join(', ')}',
          );
        }
      }
    }
  }

  return passed;
}
