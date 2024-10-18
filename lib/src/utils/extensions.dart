import 'package:rebellion/src/message_parser/messages/message.dart';
import 'package:rebellion/src/message_parser/messages/submessages/plural.dart';

/// String extensions
extension StringX on String {
  /// Return true if the string is a locale definition
  bool get isLocaleDefinition => toLowerCase() == '@@locale';

  /// Return true if the string is an at-key, e.g. "@homePageTitle"
  bool get isAtKey => startsWith('@') && !isLocaleDefinition;

  /// Return regular string key from an @-key,
  /// e.g. "@homePageTitle" -> "homePageTitle"
  String get atKeyToRegularKey {
    if (!isAtKey) throw Exception('Key must be an at-key');
    return substring(1);
  }

  /// Return regular string key from a locale definition,
  /// e.g. "@@locale" -> "locale"
  String get localeDefinitionToRegularKey {
    if (!isLocaleDefinition) throw Exception('Key must be a locale definition');
    return substring(2);
  }

  /// Return the key without the @-prefix or @@-prefix
  String get cleanKey {
    if (isLocaleDefinition) {
      return localeDefinitionToRegularKey;
    } else if (isAtKey) {
      return atKeyToRegularKey;
    } else {
      return this;
    }
  }

  /// Covert regular key to an @-key
  String get toAtKey {
    if (isAtKey) {
      throw Exception('Key must not be an at-key');
    }
    if (isLocaleDefinition) {
      throw Exception('Key must not be a locale definition');
    }

    return '@$this';
  }
}

/// [Plural] extensions
extension PluralX on Plural {
  /// Get a list of all plural attributes available in this plural
  List<String> get allPluralAttributes => [
        if (zero != null) 'zero',
        if (one != null) 'one',
        if (two != null) 'two',
        if (few != null) 'few',
        if (many != null) 'many',
        if (other != null) 'other',
      ];

  /// Get a list of all submessages available in this plural
  List<Message> get allSubmessages =>
      [zero, one, two, few, many, other].nonNulls.toList();
}
