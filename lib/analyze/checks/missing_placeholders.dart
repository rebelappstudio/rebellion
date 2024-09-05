import 'package:collection/collection.dart';
import 'package:rebellion/analyze/checks/check_base.dart';
import 'package:rebellion/message_parser/message_parser.dart';
import 'package:rebellion/message_parser/messages/composite_message.dart';
import 'package:rebellion/message_parser/messages/literal_string_message.dart';
import 'package:rebellion/message_parser/messages/message.dart';
import 'package:rebellion/message_parser/messages/submessages/gender.dart';
import 'package:rebellion/message_parser/messages/submessages/plural.dart';
import 'package:rebellion/message_parser/messages/submessages/select.dart';
import 'package:rebellion/message_parser/messages/variable_substitution_message.dart';
import 'package:rebellion/utils/arb_parser/at_key_meta.dart';
import 'package:rebellion/utils/arb_parser/parsed_arb_file.dart';
import 'package:rebellion/utils/extensions.dart';
import 'package:rebellion/utils/file_utils.dart';
import 'package:rebellion/utils/logger.dart';

/// Translation file contains @-keys without specifying the data type of the
/// placeholders
class MissingPlaceholders extends CheckBase {
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

        final mainFileContent =
            mainFile.content[key.isAtKey ? key : key.toAtKey];
        if (mainFileContent is! AtKeyMeta) continue;

        final originalString = file.content[key.cleanKey];
        final variables = getAllVariableSubstitutions(originalString);
        final definedPlaceholders = mainFileContent.placeholders;
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
          // Check if localized string
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
