import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:meta/meta.dart';

FileReader fileReader = const FileReader(fileSystem: LocalFileSystem());

/// Helper class for reading files
///
/// Uses [LocalFileSystem] by default which can be overridden for testing
@visibleForTesting
class FileReader {
  final FileSystem _fileSystem;

  const FileReader({
    required FileSystem fileSystem,
  }) : _fileSystem = fileSystem;

  String readFile(String path) {
    return _fileSystem.file(path).readAsStringSync();
  }

  bool isFileSync(String path) => _fileSystem.isFileSync(path);

  bool isDirectorySync(String path) => _fileSystem.isDirectorySync(path);

  File file(String path) => _fileSystem.file(path);

  Directory directory(String path) => _fileSystem.directory(path);
}
