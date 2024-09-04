import 'package:collection/collection.dart';
import 'package:rebellion/analyze/checks/check_base.dart';
import 'package:rebellion/message_parser.dart';
import 'package:rebellion/messages/composite_message.dart';
import 'package:rebellion/messages/literal_string_message.dart';
import 'package:rebellion/messages/message.dart';
import 'package:rebellion/messages/submessages/gender.dart';
import 'package:rebellion/messages/submessages/plural.dart';
import 'package:rebellion/messages/submessages/select.dart';
import 'package:rebellion/utils/arb_parser/parsed_arb_file.dart';
import 'package:rebellion/utils/file_utils.dart';
import 'package:rebellion/utils/logger.dart';

/// Check if there are all caps strings. This considered to be a bad practice.
/// It's better to convert to all caps programmatically
class AllCaps extends CheckBase {
  const AllCaps();

  @override
  int run(List<ParsedArbFile> files, RebellionOptions options) {
    int issues = 0;

    for (final file in files) {
      final fileLocation = file.file.filepath;
      final keys = file.keys;

      for (final key in keys) {
        final value = file.content[key];

        // Ignore unparsable strings, they're likely to be caught by
        // other checks like StringType or AtKeyType
        if (value is! String) continue;

        final result = MessageParser(value).pluralGenderSelectParse();
        final location = '$fileLocation key $key';

        if (result is Plural) {
          issues += _checkPlural(location, result);
        } else if (result is Gender) {
          issues += _checkGender(location, result);
        } else if (result is Select) {
          issues += _checkSelect(location, result);
        } else {
          // FIXME this doesn't really work
          if (_checkAllLiterals(result)) {
            issues++;
            logError('$fileLocation: all caps string key "$key"');
          }
        }
      }
    }

    return issues;
  }

  bool _isAllCapsString(String value) {
    return value.isNotEmpty && value == value.toUpperCase();
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
    return literals.any(_isAllCapsString);
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
