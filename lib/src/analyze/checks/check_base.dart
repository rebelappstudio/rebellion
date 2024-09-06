import 'package:rebellion/src/utils/arb_parser/parsed_arb_file.dart';
import 'package:rebellion/src/utils/rebellion_options.dart';

/// Simple flag-like check that can be enabled or disabled
abstract class CheckBase {
  const CheckBase();

  /// Check [files] and return number of found issues
  ///
  /// [files] - list of files to analyze
  /// [params] - parameters for the check
  int run(List<ParsedArbFile> files, RebellionOptions options);
}
