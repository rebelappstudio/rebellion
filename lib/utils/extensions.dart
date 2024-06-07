extension StringX on String {
  /// Return true if the string is a locale definition
  bool get isLocaleDefinition => toLowerCase().startsWith('@@locale');

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
}
