import 'package:args/command_runner.dart';
import 'package:rebellion/analyze/analyze.dart';
import 'package:rebellion/diff/diff.dart';
import 'package:rebellion/sort/sort.dart';

final commandRunner = CommandRunner(
  'rebellion',
  'Set of CLI tools for analyzing and translating ARB files',
)
  ..addCommand(AnalyzeCommand())
  ..addCommand(DiffCommand())
  ..addCommand(SortCommand());
