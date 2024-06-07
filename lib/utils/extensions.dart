extension StringX on String {
  /// Return true if the string is a locale definition
  bool get isLocaleDefinition => startsWith('@@locale');

  /// Return true if the string is an at-key, e.g. "@homePageTitle"
  bool get isAtKey => startsWith('@') && !isLocaleDefinition;

  /// Return regular string key from an @-key,
  /// e.g. "@homePageTitle" -> "homePageTitle"
  String get atKeyToRegularKey {
    if (!isAtKey) throw Exception('Key must be an at-key');
    return substring(1);
  }
}
