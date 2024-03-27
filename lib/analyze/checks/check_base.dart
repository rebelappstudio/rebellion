import 'package:args/args.dart';
import 'package:rebellion/icu_parser/icu_parser.dart';
import 'package:rebellion/utils/file_utils.dart';

/// Simple flag-like check that can be enabled or disabled
abstract class CheckBase {
  final String optionName;
  final bool defaultsTo;

  const CheckBase({
    required this.optionName,
    required this.defaultsTo,
  });

  /// Perform check and return the number of issues found
  ///
  /// Returns number of errors found
  ///
  /// [parser] - instance of [IcuParser] that can be used to parse strings
  /// [files] - list of files to analyze
  /// [params] - parameters for the check
  int run(IcuParser parser, List<ParsedArbFile> files);
}

/// Option-like check that need to specify a value in order to run
abstract class OptionCheckBase {
  final String optionName;
  final String? defaultsTo;
  final List<String> allowedValues;

  const OptionCheckBase({
    required this.optionName,
    required this.defaultsTo,
    required this.allowedValues,
  });

  int run(IcuParser parser, List<ParsedArbFile> files, ArgResults? args);
}
