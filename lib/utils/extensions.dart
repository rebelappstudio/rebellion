extension StringX on String {
  bool get isLocaleDefinition => startsWith('@@');

  bool get isAtKey => startsWith('@') && !isLocaleDefinition;

  String get atKeyToRegularKey {
    if (!isAtKey) throw Exception('Key must be an at-key');
    return substring(1);
  }
}
