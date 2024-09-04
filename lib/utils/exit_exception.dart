/// This exception is thrown when the program should exit
///
/// An exception is used instead of directly calling exit(1) to make testing
/// easier. Outside of tests exit(1) is called to stop the program immediately
class ExitException implements Exception {}
