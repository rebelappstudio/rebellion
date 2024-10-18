import 'package:rebellion/src/utils/arb_parser/parsed_arb_file.dart';
import 'package:rebellion/src/utils/rebellion_options.dart';

/// Simple flag-like rule that can be enabled or disabled
abstract class Rule {
  /// Default constructor
  const Rule();

  /// Check [files] and return number of found issues
  int run(List<ParsedArbFile> files, RebellionOptions options);
}
