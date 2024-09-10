import 'package:collection/collection.dart';
import 'package:rebellion/src/analyze/rules/rule.dart';
import 'package:rebellion/src/message_parser/message_parser.dart';
import 'package:rebellion/src/message_parser/messages/composite_message.dart';
import 'package:rebellion/src/message_parser/messages/literal_string_message.dart';
import 'package:rebellion/src/message_parser/messages/message.dart';
import 'package:rebellion/src/message_parser/messages/submessages/gender.dart';
import 'package:rebellion/src/message_parser/messages/submessages/plural.dart';
import 'package:rebellion/src/message_parser/messages/submessages/select.dart';
import 'package:rebellion/src/message_parser/messages/variable_substitution_message.dart';
import 'package:rebellion/src/utils/arb_parser/at_key_meta.dart';
import 'package:rebellion/src/utils/arb_parser/parsed_arb_file.dart';
import 'package:rebellion/src/utils/extensions.dart';
import 'package:rebellion/src/utils/logger.dart';
import 'package:rebellion/src/utils/rebellion_options.dart';

/// Translation file contains @-keys without specifying the data type of the
/// placeholders
class MissingPlaceholders extends Rule {
  const MissingPlaceholders();

  @override
  int run(List<ParsedArbFile> files, RebellionOptions options) {
    var issues = 0;

    // Use main file to get all placeholders as it should be the source of them
    final mainFile = files.firstWhere((e) => e.file.isMainFile);

    for (final file in files) {
      for (final key in file.keys) {
        final isMainFile = file.file.isMainFile;
        if (key.isLocaleDefinition) continue;

        // For main file check @-keys only. For other files check all keys
        // because it's expected that @-keys are only in the main file
        if (isMainFile && !key.isAtKey) continue;

        final mainFileContent = mainFile
            .content[key.isAtKey ? key.atKeyToRegularKey : key] as String?;
        if (mainFileContent == null) continue;

        final mainFileAtKey = mainFile.content[key.isAtKey ? key : key.toAtKey];
        if (mainFileAtKey is! AtKeyMeta) continue;

        final originalString = file.content[key.cleanKey];
        final variablesMain = getAllVariableSubstitutions(mainFileContent);
        final variables = getAllVariableSubstitutions(originalString);
        final definedPlaceholders = mainFileAtKey.placeholders;
        final placeholderNames = definedPlaceholders
            .map((e) => e.name)
            .whereNot((e) => e == null || e.isEmpty)
            .toList();

        if (isMainFile) {
          if (placeholderNames.isEmpty && variables.isNotEmpty) {
            issues++;
            logError(
              '${file.file.filepath}: key "$key" is missing placeholders definition',
            );
          }

          // Check placeholder names and types for main file only
          for (final placeholder in definedPlaceholders) {
            if (placeholder.name?.isEmpty ?? true) {
              issues++;
              logError(
                '${file.file.filepath}: key "$key" is missing a placeholder name',
              );
            }

            if (placeholder.type?.isEmpty ?? true) {
              issues++;
              logError(
                '${file.file.filepath}: key "$key" is missing a placeholder type for "${placeholder.name}"',
              );
            }
          }
        } else {
          // It's possible that main file uses plural placeholders just to get
          // the correct plural form without actually using them in the string.
          // For example: {count, plurals, one {1 item} other {More items}}
          // In this case, no need to check for missing or redundant
          // placeholders
          if (variablesMain.isEmpty && variables.isEmpty) continue;

          // Check if localized string has the same placeholders as the main file
          if (!ListEquality().equals(variables, placeholderNames)) {
            issues++;
            logError(
              '${file.file.filepath}: key "$key" has different placeholders than the main file: $variables vs $placeholderNames',
            );
          }
        }
      }
    }

    return issues;
  }
}

List<String> getAllVariableSubstitutions(String string) {
  final parser = MessageParser(string);
  Message message = parser.pluralGenderSelectParse();

  if (message is! Plural && message is! Gender && message is! Select) {
    message = parser.nonIcuMessageParse();
  }

  if (message is LiteralString) {
    return const [];
  } else if (message is CompositeMessage) {
    return getVariableSubstitutionsFromCompositeMessage(message);
  } else if (message is Plural) {
    return message.allSubmessages
        .whereType<CompositeMessage>()
        .map((m) => getVariableSubstitutionsFromCompositeMessage(m))
        .flattened
        .toList();
  }

  return const [];
}

List<String> getVariableSubstitutionsFromCompositeMessage(
  CompositeMessage message,
) {
  return message.pieces
      .whereType<VariableSubstitution>()
      .map((e) => e.variableName)
      .nonNulls
      .toList();
}
