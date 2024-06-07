import 'package:rebellion/analyze/checks/check_base.dart';
import 'package:rebellion/generated/plural_rules.dart';
import 'package:rebellion/message_parser.dart';
import 'package:rebellion/messages/submessages/plural.dart';
import 'package:rebellion/utils/extensions.dart';
import 'package:rebellion/utils/file_utils.dart';
import 'package:rebellion/utils/logger.dart';

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

        final value = file.content[key] as String;
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
        if (missingPlurals.isNotEmpty) {
          issues++;
          logError(
            '${file.file.filepath} key $key: missing plural values: ${missingPlurals.join(', ')}',
          );
        }

        // Check redundant plurals (plurals that are in the file but
        // not in plural rules)
        final redundantPlurals = result.allPluralAttributes
            .where((e) => !pluralRulesForLocale.contains(e));
        if (redundantPlurals.isNotEmpty) {
          issues++;
          logError(
            '${file.file.filepath} key $key: redundant plural values: ${redundantPlurals.join(', ')}',
          );
        }
      }
    }

    return issues;
  }
}

extension _PluralX on Plural {
  /// Get a list of all plural attributes available in this plural
  List<String> get allPluralAttributes => [
        if (zero != null) 'zero',
        if (one != null) 'one',
        if (two != null) 'two',
        if (few != null) 'few',
        if (many != null) 'many',
        if (other != null) 'other',
      ];
}
