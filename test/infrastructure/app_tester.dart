import 'package:file/memory.dart';
import 'package:rebellion/src/utils/file_reader.dart';
import 'package:rebellion/src/utils/logger.dart';
import 'package:rebellion/src/utils/rebellion_options.dart';

import 'logger.dart';

class AppTester {
  const AppTester._();

  static AppTester create() {
    // Create fake file system and override fileReader
    final fileSystem = MemoryFileSystem.test();
    fileReader = FileReader(fileSystem: fileSystem);

    // Override logger to be able to check the output in tests
    logger = inMemoryLogger..clear();

    return const AppTester._();
  }

  void setConfigFile(String content) {
    fileReader.file(configFilename).writeAsStringSync(content);
  }

  void populateFileSystem(Map<String, String> files) {
    for (final entry in files.entries) {
      fileReader.file(entry.key).writeAsStringSync(entry.value);
    }
  }

  String getFileContent(String filepath) {
    return fileReader.readFile(filepath);
  }
}
