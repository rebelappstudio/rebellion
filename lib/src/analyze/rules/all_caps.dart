import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:rebellion/src/analyze/analyzer_options.dart';
import 'package:rebellion/src/analyze/rules/rule.dart';
import 'package:rebellion/src/message_parser/message_parser.dart';
import 'package:rebellion/src/message_parser/messages/composite_message.dart';
import 'package:rebellion/src/message_parser/messages/literal_string_message.dart';
import 'package:rebellion/src/message_parser/messages/message.dart';
import 'package:rebellion/src/message_parser/messages/submessages/gender.dart';
import 'package:rebellion/src/message_parser/messages/submessages/plural.dart';
import 'package:rebellion/src/message_parser/messages/submessages/select.dart';
import 'package:rebellion/src/utils/arb_parser/at_key_meta.dart';
import 'package:rebellion/src/utils/arb_parser/parsed_arb_file.dart';
import 'package:rebellion/src/utils/extensions.dart';
import 'package:rebellion/src/utils/logger.dart';

// Regular expression to match all upper case letters. For example:
// * 'HELLO' -> match
// * 'Hello' -> no match
// * 'A-1' -> no match
final _upperCaseLettersRegExp = RegExp(r'^\p{Lu}+$', unicode: true);

/// Check if there are all caps strings. This considered to be a bad practice.
/// It's better to convert to all caps programmatically
class AllCaps extends Rule {
  /// Default constructor
  const AllCaps();

  @override
  int run(List<ParsedArbFile> files, AnalyzerOptions options) {
    int issues = 0;

    for (final file in files) {
      final fileLocation = file.file.filepath;
      final keys = file.keys;

      for (final key in keys) {
        final value = file.content[key];

        final atKey = file.content[key.toAtKey];
        if (atKey is AtKeyMeta && atKey.isRuleIgnored(RuleKey.allCaps)) {
          continue;
        }

        // Ignore unparsable strings, they're likely to be caught by
        // other checks like StringType or AtKeyType
        if (value is! String) continue;

        final parser = MessageParser(value);
        var result = parser.pluralGenderSelectParse();
        if (result is! Plural && result is! Gender && result is! Select) {
          result = parser.nonIcuMessageParse();
        }

        final location = '$fileLocation key $key';

        if (result is Plural) {
          issues += _checkPlural(location, result);
        } else if (result is Gender) {
          issues += _checkGender(location, result);
        } else if (result is Select) {
          issues += _checkSelect(location, result);
        } else {
          if (_checkAllLiterals(result)) {
            issues++;
            logError('$fileLocation: all caps string key "$key"');
          }
        }
      }
    }

    return issues;
  }

  /// Check if the [value] string contains only upper case letters
  @visibleForTesting
  static bool isAllCapsString(String value) {
    final newValue = value.replaceAll(' ', '');

    // Special case for single character string, e.g. `A`, or `A {placeholder}`
    if (newValue.length == 1) return false;

    if (newValue.isEmpty) return false;

    return _upperCaseLettersRegExp.hasMatch(newValue);
  }

  int _checkPlural(String location, Plural plural) {
    int issues = 0;
    final zero = plural.zero;
    final one = plural.one;
    final two = plural.two;
    final few = plural.few;
    final many = plural.many;
    final other = plural.other;

    if (_checkAllLiterals(zero)) {
      issues++;
      logError('$location: all caps string in case "zero"');
    }

    if (_checkAllLiterals(one)) {
      issues++;
      logError('$location: all caps string in case "one"');
    }

    if (_checkAllLiterals(two)) {
      issues++;
      logError('$location: all caps string in case "two"');
    }

    if (_checkAllLiterals(few)) {
      issues++;
      logError('$location: all caps string in case "few"');
    }

    if (_checkAllLiterals(many)) {
      issues++;
      logError('$location: all caps string in case "many"');
    }

    if (_checkAllLiterals(other)) {
      issues++;
      logError('$location: all caps string in case "other"');
    }

    return issues;
  }

  int _checkGender(String location, Gender gender) {
    int issues = 0;
    final female = gender.female;
    final male = gender.male;
    final other = gender.other;

    if (_checkAllLiterals(female)) {
      issues++;
      logError('$location: all caps string in case "female"');
    }

    if (_checkAllLiterals(male)) {
      issues++;
      logError('$location: all caps string in case "male"');
    }

    if (_checkAllLiterals(other)) {
      issues++;
      logError('$location: all caps string in case "other"');
    }

    return issues;
  }

  int _checkSelect(String location, Select select) {
    int issues = 0;
    for (final key in select.cases.keys) {
      final value = select.cases[key];
      if (_checkAllLiterals(value)) {
        issues++;
        logError('$location: all caps string in case "$key"');
      }
    }

    return issues;
  }

  bool _checkAllLiterals(Message? message) {
    if (message == null) return false;

    final literals = allMessageLiterals(message);
    return literals.any(isAllCapsString);
  }
}

/// Returns all message literals in a message and its children
List<String> allMessageLiterals(Message message) {
  if (message is LiteralString) {
    return [message.string];
  } else if (message is CompositeMessage) {
    return message.pieces.map(allMessageLiterals).flattened.toList();
  }

  return const [];
}
