import 'package:rebellion/src/utils/arb_parser/arb_file.dart';
import 'package:rebellion/src/utils/arb_parser/parsed_arb_file.dart';
import 'package:test/test.dart';

void main() {
  test('locale returns file locale code', () {
    var parsedArbFile = ParsedArbFile(
      file: ArbFile(
        filepath: 'strings_en.arb',
        filenameLocale: 'en',
        isMainFile: true,
      ),
      content: {
        '@@locale': 'en',
      },
      rawKeys: [],
    );
    expect(parsedArbFile.locale, 'en');

    parsedArbFile = ParsedArbFile(
      file: ArbFile(
        filepath: 'strings_fi.arb',
        filenameLocale: 'fi',
        isMainFile: true,
      ),
      content: {
        '@@locale': 'en',
      },
      rawKeys: [],
    );
    expect(parsedArbFile.locale, 'en');

    parsedArbFile = ParsedArbFile(
      file: ArbFile(
        filepath: 'strings_fi.arb',
        filenameLocale: 'fi',
        isMainFile: true,
      ),
      content: {},
      rawKeys: [],
    );
    expect(parsedArbFile.locale, 'fi');
  });
}
