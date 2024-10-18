import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:meta/meta.dart';

/// Default instance of [FileReader] for getting access to the file system
///
/// Might be overridden for testing
FileReader fileReader = const FileReader(fileSystem: LocalFileSystem());

/// Helper class for reading files
///
/// Uses [LocalFileSystem] by default which can be overridden for testing
@visibleForTesting
class FileReader {
  final FileSystem _fileSystem;

  /// Default constructor
  const FileReader({
    required FileSystem fileSystem,
  }) : _fileSystem = fileSystem;

  /// Read file content
  String readFile(String path) {
    return _fileSystem.file(path).readAsStringSync();
  }

  /// Check if file exists
  bool isFileSync(String path) => _fileSystem.isFileSync(path);

  /// Check if directory exists
  bool isDirectorySync(String path) => _fileSystem.isDirectorySync(path);

  /// Get a reference to a file
  File file(String path) => _fileSystem.file(path);

  /// Get a reference to a directory
  Directory directory(String path) => _fileSystem.directory(path);
}
