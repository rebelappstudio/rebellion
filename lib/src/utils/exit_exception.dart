/// This exception is thrown when the program should exit
///
/// An exception is used instead of directly calling exit(2) to make testing
/// easier. Outside of tests exit(2) is called to stop the program immediately
///
/// Exit code 2 is used to let system know that tool has exited with an error:
/// https://dart.dev/tutorials/server/cmdline#setting-exit-codes
class ExitException implements Exception {}
