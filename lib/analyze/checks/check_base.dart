import 'package:rebellion/icu_parser/icu_parser.dart';
import 'package:rebellion/utils/file_utils.dart';

/// Simple flag-like check that can be enabled or disabled
abstract class CheckBase {
  const CheckBase();

  /// Perform check and return the number of issues found
  ///
  /// Returns number of errors found
  ///
  /// [parser] - instance of [IcuParser] that can be used to parse strings
  /// [files] - list of files to analyze
  /// [params] - parameters for the check
  int run(
    IcuParser parser,
    List<ParsedArbFile> files,
    RebellionOptions options,
  );
}
