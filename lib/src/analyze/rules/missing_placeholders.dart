import 'package:collection/collection.dart';
import 'package:rebellion/src/analyze/analyzer_options.dart';
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

/// Checks whether translation strings contain all variables defined in the main
/// file and don't have any extra variables
class MissingPlaceholders extends Rule {
  /// Default constructor
  const MissingPlaceholders();

  @override
  int run(List<ParsedArbFile> files, AnalyzerOptions options) {
    var issues = 0;

    // Only check if main file is available
    if (!options.containsMainFile) return issues;

    // Use main file to get all placeholders as it should be the source of them
    final mainFile = files.firstWhere((e) => e.file.isMainFile);

    for (final file in files) {
      for (final key in file.keys) {
        final isMainFile = file.file.isMainFile;
        if (key.isLocaleDefinition) continue;

        // For main file check @-keys only
        if (isMainFile && !key.isAtKey) continue;

        // For other files use translation keys only. It's expected that
        // translation files don't have @-keys (caught by [RedundantAtKey])
        if (!isMainFile && key.isAtKey) continue;

        final mainFileContent = mainFile.content[key.cleanKey] as String?;
        if (mainFileContent == null) continue;

        final mainFileAtKey = mainFile.content[key.toAtKey];
        if (mainFileAtKey is! AtKeyMeta) continue;

        final atKey = file.content[key.toAtKey];
        if (atKey is AtKeyMeta &&
            atKey.isRuleIgnored(RuleKey.missingPlaceholders)) {
          continue;
        }

        // Placeholders actually used in the string
        final mainKeyUsedPlaceholders =
            getAllVariableSubstitutions(mainFileContent).toSet();

        // Placeholders defined in the main file (may or may not be used in
        // the string as variables)
        final definedPlaceholdersMain = mainFileAtKey.placeholders;
        final definedMainFilePlaceholderNames = definedPlaceholdersMain
            .map((e) => e.name)
            .nonNulls
            .whereNot((e) => e.isEmpty)
            .toSet();

        final keyContent = file.content[key.cleanKey];
        final keyPlaceholders = getAllVariableSubstitutions(keyContent).toSet();

        if (isMainFile) {
          if (definedMainFilePlaceholderNames.isEmpty &&
              keyPlaceholders.isNotEmpty) {
            issues++;
            logError(
              '${file.file.filepath}: key "$key" is missing placeholders definition',
            );
          }

          // Check if there are any defined but unused placeholders
          final unusedPlaceholders = definedMainFilePlaceholderNames
              .where((e) => !mainKeyUsedPlaceholders.contains(e))
              .toSet();
          if (mainKeyUsedPlaceholders.isNotEmpty &&
              unusedPlaceholders.isNotEmpty) {
            issues++;
            _logUnusedPlaceholders(file, key, unusedPlaceholders);
          }

          // Check placeholder names and types for main file only
          for (final placeholder in definedPlaceholdersMain) {
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
          if (mainKeyUsedPlaceholders.isEmpty && keyPlaceholders.isEmpty) {
            continue;
          }

          final allDefinedVariables = {
            ...mainKeyUsedPlaceholders,
            ...definedMainFilePlaceholderNames,
          };
          // Placeholders present in translation but not defined or used in the
          // main file
          final extraPlaceholders =
              keyPlaceholders.where((v) => !allDefinedVariables.contains(v));

          // Placeholders defined in the main file but not used in the
          // translation
          final missingPlaceholders =
              allDefinedVariables.where((v) => !keyPlaceholders.contains(v));

          if (missingPlaceholders.isNotEmpty) {
            issues++;
            _logMissingPlaceholders(file, key, missingPlaceholders);
          }

          if (extraPlaceholders.isNotEmpty) {
            issues++;
            _logExtraPlaceholders(file, key, extraPlaceholders);
          }
        }
      }
    }

    return issues;
  }

  void _logUnusedPlaceholders(
    ParsedArbFile file,
    String key,
    Iterable<String> placeholders,
  ) {
    logError(
      placeholders.length == 1
          ? '${file.file.filepath}: key "$key" defines a placeholder that is not used in the string: ${placeholders.first}'
          : '${file.file.filepath}: key "$key" defines placeholders that are not used in the string: ${placeholders.join(', ')}',
    );
  }

  void _logMissingPlaceholders(
    ParsedArbFile file,
    String key,
    Iterable<String> placeholders,
  ) {
    logError(
      placeholders.length == 1
          ? '${file.file.filepath}: key "$key" is missing a placeholder defined in the main file: ${placeholders.first}'
          : '${file.file.filepath}: key "$key" is missing placeholders defined in the main file: ${placeholders.join(', ')}',
    );
  }

  void _logExtraPlaceholders(
    ParsedArbFile file,
    String key,
    Iterable<String> placeholders,
  ) {
    logError(
      placeholders.length == 1
          ? '${file.file.filepath}: key "$key" uses a placeholder not present in the main file: ${placeholders.first}'
          : '${file.file.filepath}: key "$key" uses placeholders not present in the main file: ${placeholders.join(', ')}',
    );
  }
}

/// Get all variable substitutions from the [string]
///
/// E.g. "Hello, {name}" returns ["name"]
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

/// Get all variable substitutions from the composite [message]
List<String> getVariableSubstitutionsFromCompositeMessage(
  CompositeMessage message,
) {
  return message.pieces
      .whereType<VariableSubstitution>()
      .map((e) => e.variableName)
      .nonNulls
      .toList();
}
