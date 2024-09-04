import 'dart:io';

import 'package:rebellion/command_runner.dart';
import 'package:rebellion/utils/exit_exception.dart';

void main(List<String> arguments) {
  try {
    commandRunner.run(arguments);
  } on ExitException {
    // Handle ExitException when running program from CLI
    exit(2);
  }
}
