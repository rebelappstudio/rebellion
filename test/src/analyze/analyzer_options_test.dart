import 'package:rebellion/src/analyze/analyzer_options.dart';
import 'package:rebellion/src/utils/arb_parser/arb_file.dart';
import 'package:rebellion/src/utils/arb_parser/parsed_arb_file.dart';
import 'package:rebellion/src/utils/rebellion_options.dart';
import 'package:test/test.dart';

void main() {
  test('AnalyzerOptions.fromFiles creates correct values', () async {
    final rebellionOptions = RebellionOptions.empty();
    var options = AnalyzerOptions.fromFiles(
      files: [],
      rebellionOptions: rebellionOptions,
    );
    expect(options.rebellionOptions, rebellionOptions);
    expect(options.isSingleFile, false);
    expect(options.containsMainFile, false);

    options = AnalyzerOptions.fromFiles(
      files: [
        ParsedArbFile(
          file: ArbFile(filepath: '', filenameLocale: 'fi', isMainFile: false),
          content: {},
          rawKeys: [],
        ),
      ],
      rebellionOptions: rebellionOptions,
    );
    expect(options.rebellionOptions, rebellionOptions);
    expect(options.isSingleFile, true);
    expect(options.containsMainFile, false);

    options = AnalyzerOptions.fromFiles(
      files: [
        ParsedArbFile(
          file: ArbFile(filepath: '', filenameLocale: 'en', isMainFile: true),
          content: {},
          rawKeys: [],
        ),
      ],
      rebellionOptions: rebellionOptions,
    );
    expect(options.rebellionOptions, rebellionOptions);
    expect(options.isSingleFile, true);
    expect(options.containsMainFile, true);

    options = AnalyzerOptions.fromFiles(
      files: [
        ParsedArbFile(
          file: ArbFile(filepath: '', filenameLocale: 'en', isMainFile: true),
          content: {},
          rawKeys: [],
        ),
        ParsedArbFile(
          file: ArbFile(filepath: '', filenameLocale: 'fi', isMainFile: false),
          content: {},
          rawKeys: [],
        ),
      ],
      rebellionOptions: rebellionOptions,
    );
    expect(options.rebellionOptions, rebellionOptions);
    expect(options.isSingleFile, false);
    expect(options.containsMainFile, true);
  });
}
