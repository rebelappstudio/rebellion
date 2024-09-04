import 'package:rebellion/utils/arb_parser/parsed_arb_file.dart';
import 'package:rebellion/utils/file_utils.dart';

/// Simple flag-like check that can be enabled or disabled
abstract class CheckBase {
  const CheckBase();

  /// Check [files] and return number of found issues
  ///
  /// [parser] - instance of [IcuParser] that can be used to parse strings
  /// [files] - list of files to analyze
  /// [params] - parameters for the check
  int run(List<ParsedArbFile> files, RebellionOptions options);
}
