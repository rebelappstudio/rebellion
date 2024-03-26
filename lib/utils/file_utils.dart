import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as path;
import 'package:rebellion/utils/logger.dart';

// TODO move to a separate file
class ArbFile {
  final String filepath;
  final String locale;
  final bool isMainFile;

  const ArbFile({
    required this.filepath,
    required this.locale,
    required this.isMainFile,
  });
}

// TODO move to a separate file
class ParsedArbFile {
  final ArbFile file;
  final Map<String, dynamic> content;

  /// All keys including duplicates if any
  final List<String> rawKeys;

  const ParsedArbFile({
    required this.file,
    required this.content,
    required this.rawKeys,
  });

  List<String> get keys => content.keys.toList();

  List<dynamic> get atKeys =>
      content.keys.where((key) => key.startsWith('@')).toList();

  ParsedArbFile copyWith({Map<String, dynamic>? content}) {
    return ParsedArbFile(
      file: file,
      content: content ?? this.content,
      rawKeys: rawKeys,
    );
  }
}

/// Get all strings from [filename] file
/// dynamic type is used because ARB files can contain placeholders as JSON
/// structures
ParsedArbFile loadStrings(ArbFile file) {
  final filepath = path.join(file.filepath);
  final arbContent = File(filepath).readAsStringSync();
  final rawKeys = <String>[];
  final content = json.decode(arbContent, reviver: (key, value) {
    if (key is String) rawKeys.add(key);
    return value;
  });

  return ParsedArbFile(
    file: file,
    content: content as Map<String, dynamic>,
    rawKeys: rawKeys,
  );
}

/// Get list of all .arb files except the main file
/// Returns list of tuples (Target language, ARB filename)
List<ArbFile> getArbFiles(List<String> filesAndFolders, String mainLocale) {
  final files = _getAllFiles(filesAndFolders);
  return files.map((file) {
    // TODO ignore ".diff.arb" files
    // TODO this could be improved: e.g. en_US will not work
    final filename = path.basenameWithoutExtension(file.path);
    final locale = filename.substring(filename.lastIndexOf('_') + 1);

    return ArbFile(
      filepath: file.path,
      locale: locale,
      isMainFile: locale == mainLocale,
    );
  }).toList();

  // .where((file) {
  //   final baseName = path.basename(file.path);
  //   return baseName.toLowerCase() != _mainFile &&
  //       baseName.toLowerCase().endsWith('.arb');
  // }).map((e) {
  //   final filename = path.basename(e.path);
  //   // return (TargetLanguage.fromFilename(filename), filename);
  //   return ArbFile(path: path);
  // }).toList();
}

List<File> _getAllFiles(List<String> filesAndFolders) {
  final files = <File>[];
  for (final item in filesAndFolders) {
    final isFile = FileSystemEntity.isFileSync(item);
    if (isFile) {
      files.add(File(item));
    } else {
      final directory = Directory(item);
      files.addAll(directory.listSync().whereType<File>());
    }
  }

  return files;
}

// TODO move
const mainLocaleParam = 'main-locale';
const defaultMainLocale = 'en';

List<ParsedArbFile> getFilesAndFolders(ArgResults? argResults) {
  final mainLocale = argResults?[mainLocaleParam] as String;
  final filesAndFolders = argResults?.rest ?? const [];
  _ensureFilesAndFoldersExist(filesAndFolders);

  final arbFiles = getArbFiles(filesAndFolders, mainLocale);
  _ensureArbFilesValid(arbFiles);

  return arbFiles.map(loadStrings).toList();
}

void writeArbFile(Map<String, dynamic> content, String filename) {
  final encoder = JsonEncoder.withIndent('  ');
  final jsonContent = encoder.convert(content);
  final file = File(filename);
  file.writeAsStringSync(jsonContent);
}

void _ensureFilesAndFoldersExist(List<String> filesAndFolders) {
  if (filesAndFolders.isEmpty) {
    // TODO fall back to current directory and let user know about it
    logError('No files or folders to analyze');
    exit(1);
  }

  for (final item in filesAndFolders) {
    final itemExist = FileSystemEntity.isDirectorySync(item) ||
        FileSystemEntity.isFileSync(item);
    if (!itemExist) {
      logError('$item does not exist');
      exit(1);
    }
  }
}

/// Make sure all ARB files are valid JSON files. Other checks may not work
/// unless this one passes
void _ensureArbFilesValid(List<ArbFile> arbFiles) {
  bool arbFilesValid = true;
  for (final arbFile in arbFiles) {
    try {
      loadStrings(arbFile);
    } catch (error, stackTrace) {
      print(error);
      print(stackTrace);

      arbFilesValid = false;
      logError('${arbFile.filepath}: file content is not a valid JSON');
    }
  }

  if (!arbFilesValid) {
    exit(1);
  }
}
