import 'dart:io';

import 'package:rebellion/src/utils/command_runner.dart';
import 'package:rebellion/src/utils/exit_exception.dart';

Future<void> main(List<String> arguments) async {
  try {
    await commandRunner.run(arguments);
  } on ExitException {
    // Handle ExitException when running program from CLI and exit with the
    // error code
    exit(2);
  }
}
