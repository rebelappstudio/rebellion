import 'package:rebellion/src/analyze/checks/check_base.dart';
import 'package:rebellion/src/generated/plural_rules.dart';
import 'package:rebellion/src/message_parser/message_parser.dart';
import 'package:rebellion/src/message_parser/messages/submessages/plural.dart';
import 'package:rebellion/src/utils/arb_parser/parsed_arb_file.dart';
import 'package:rebellion/src/utils/extensions.dart';
import 'package:rebellion/src/utils/logger.dart';
import 'package:rebellion/src/utils/rebellion_options.dart';

/// Check if there are missing plurals in main file and translations
class MissingPlurals extends CheckBase {
  const MissingPlurals();

  @override
  int run(List<ParsedArbFile> files, RebellionOptions options) {
    int issues = 0;

    final pluralRules = PluralRules();

    for (final file in files) {
      for (final key in file.keys) {
        if (key.isAtKey) continue;
        if (key.isLocaleDefinition) continue;

        final value = file.content[key];
        // Ignore unparsable strings, they're likely to be caused by
        // other checks like StringType or AtKeyType
        if (value is! String) continue;

        final result = MessageParser(value).pluralGenderSelectParse();
        if (result is! Plural) continue;

        final pluralRulesForLocale = pluralRules[file.file.locale];
        if (pluralRulesForLocale.isEmpty) {
          throw Exception(
            'Failed to find plural rules for ${file.file.locale}',
          );
        }

        // Check missing plurals (plurals that are in plural rules but
        // not in the file)
        final missingPlurals = pluralRulesForLocale
            .where((e) => !result.allPluralAttributes.contains(e));
        for (final plural in missingPlurals) {
          issues++;
          logError(
            '${file.file.filepath} key "$key" is missing a plural value "$plural"',
          );
        }

        // Check redundant plurals (plurals that are in the file but
        // not in plural rules)
        final redundantPlurals = result.allPluralAttributes
            .where((e) => !pluralRulesForLocale.contains(e));
        for (final plural in redundantPlurals) {
          issues++;
          logError(
            '${file.file.filepath} key "$key" contains a redundant plural value "$plural"',
          );
        }
      }
    }

    return issues;
  }
}
