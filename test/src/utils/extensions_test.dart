import 'package:rebellion/src/utils/extensions.dart';
import 'package:test/test.dart';

void main() {
  test('isLocaleDefinition detects locale definition', () {
    expect('@@locale'.isLocaleDefinition, isTrue);
    expect('@locale'.isLocaleDefinition, isFalse);
    expect('locale'.isLocaleDefinition, isFalse);
    expect('@@@locale'.isLocaleDefinition, isFalse);
    expect('@key_locale'.isLocaleDefinition, isFalse);
  });

  test('isAtKey detects @-key', () {
    expect('@key'.isAtKey, isTrue);
    expect('key'.isAtKey, isFalse);
    expect('@@locale'.isAtKey, isFalse);
  });

  test('At key can be converted to a regular key', () {
    expect('@key'.atKeyToRegularKey, 'key');
    expect(() => 'key'.atKeyToRegularKey, throwsException);
    expect(() => '@@locale'.atKeyToRegularKey, throwsException);
  });

  test('Any key can be converted to a clean key', () {
    expect('@key'.cleanKey, 'key');
    expect('@key_1'.cleanKey, 'key_1');
    expect('@keyOne'.cleanKey, 'keyOne');
    expect('key'.cleanKey, 'key');
    expect('key_1'.cleanKey, 'key_1');
    expect('keyOne'.cleanKey, 'keyOne');
    expect('@@locale'.cleanKey, 'locale');
  });

  test('Regular key can be converted to @-key', () {
    expect('key'.toAtKey, '@key');
    expect('key_1'.toAtKey, '@key_1');
    expect('keyOne'.toAtKey, '@keyOne');
    expect('@key'.toAtKey, '@key');
    expect('@@locale'.toAtKey, '@@locale');
  });
}
