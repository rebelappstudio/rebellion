import 'package:args/command_runner.dart';
import 'package:rebellion/analyze.dart';
import 'package:rebellion/diff.dart';
import 'package:rebellion/sort.dart';
import 'package:rebellion/translate/translate.dart';

/// TODO analyze
///   // unused translations (l10nization_cli lib)
///   // hardcoded strings (string_literal_finder lib)
///
/// translate // translate _missing_ items
///   -key <key> // OpenAI key
///   -from // language from
///   -to // language to
void main(List<String> arguments) {
  CommandRunner(
    'rebellion',
    'Set of CLI tools for analyzing and translating ARB files',
  )
    ..addCommand(AnalyzeCommand())
    ..addCommand(TranslateCommand())
    ..addCommand(DiffCommand())
    ..addCommand(SortCommand())
    ..run(arguments);
}
