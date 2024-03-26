import 'package:rebellion/parser/icu_parser.dart';
import 'package:rebellion/utils/file_utils.dart';

// TODO use this class? How to pass params?
abstract class CheckBase {
  /// Perform check and return the number of errors found
  ///
  /// [parser] - instance of [IcuParser] that can be used to parse strings
  /// [files] - list of files to analyze
  /// [params] - parameters for the check
  int check(
    IcuParser parser,
    List<ParsedArbFile> files,
    Map<String, dynamic> params,
  );
}
