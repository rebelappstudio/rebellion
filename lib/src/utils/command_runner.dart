import 'package:args/command_runner.dart';
import 'package:rebellion/src/analyze/analyze.dart';
import 'package:rebellion/src/diff/diff.dart';
import 'package:rebellion/src/sort/sort.dart';

/// A [CommandRunner] for the rebellion CLI tool
final commandRunner = CommandRunner(
  'rebellion',
  'Set of CLI tools for analyzing and translating ARB files',
)
  ..addCommand(AnalyzeCommand())
  ..addCommand(DiffCommand())
  ..addCommand(SortCommand());
