import 'dart:convert';

import 'package:args/args.dart';
import 'package:file/file.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;
import 'package:rebellion/src/utils/arb_parser/arb_file.dart';
import 'package:rebellion/src/utils/arb_parser/arb_parser.dart';
import 'package:rebellion/src/utils/arb_parser/parsed_arb_file.dart';
import 'package:rebellion/src/utils/exit_exception.dart';
import 'package:rebellion/src/utils/file_reader.dart';
import 'package:rebellion/src/utils/logger.dart';
import 'package:rebellion/src/utils/rebellion_options.dart';
import 'package:yaml/yaml.dart';

@visibleForTesting
const configFilename = 'rebellion_options.yaml';

/// Get list of all .arb files except the main file
/// Returns list of tuples (Target language, ARB filename)
List<ArbFile> getArbFiles(List<String> filesAndFolders, String mainLocale) {
  final files = _getAllFiles(filesAndFolders);
  return files
      .map((file) {
        final filename = path.basenameWithoutExtension(file.path);

        // Ignore diff files
        if (filename.endsWith('_diff')) return null;

        final underscoreIndex = filename.lastIndexOf('_');
        if (underscoreIndex == -1) return null;

        final locale = filename.substring(underscoreIndex + 1);
        return ArbFile(
          filepath: file.path,
          locale: locale,
          isMainFile: locale == mainLocale,
        );
      })
      .nonNulls
      .toList();
}

List<File> _getAllFiles(List<String> filesAndFolders) {
  final files = <File>[];
  for (final item in filesAndFolders) {
    final isFile = fileReader.isFileSync(item);
    if (isFile) {
      files.add(fileReader.file(item));
    } else {
      final directory = fileReader.directory(item);
      files.addAll(directory.listSync().whereType<File>());
    }
  }

  return files;
}

List<ParsedArbFile> getFilesAndFolders(
  RebellionOptions options,
  ArgResults? argResults,
) {
  final mainLocale = options.mainLocale;
  final filesAndFolders = argResults?.rest ?? const [];
  _ensureFilesAndFoldersExist(filesAndFolders);

  return getArbFiles(filesAndFolders, mainLocale).map(parseArbFile).toList();
}

void writeArbFile(Map<String, dynamic> content, String filename) {
  final encoder = JsonEncoder.withIndent('  ');
  final jsonContent = encoder.convert(content);
  final file = fileReader.file(filename);
  file.writeAsStringSync(jsonContent);
}

void writeArbFiles(List<ParsedArbFile> files) {
  for (final file in files) {
    writeArbFile(file.content, file.file.filepath);
  }
}

void _ensureFilesAndFoldersExist(List<String> filesAndFolders) {
  if (filesAndFolders.isEmpty) {
    logError('No files or folders to analyze');
    throw ExitException();
  }

  for (final item in filesAndFolders) {
    final itemExist =
        fileReader.isDirectorySync(item) || fileReader.isFileSync(item);
    if (!itemExist) {
      logError('$item does not exist');
      throw ExitException();
    }
  }
}

RebellionOptions loadOptionsYaml() {
  if (!fileReader.file(configFilename).existsSync()) {
    return RebellionOptions.empty();
  }

  final fileContent = fileReader.readFile(configFilename);
  final yaml = loadYaml(fileContent) as YamlMap;

  final rules = yaml.nodes['rules'] as YamlList?;
  final options = yaml.nodes['options'] as YamlMap?;
  return RebellionOptions.fromYaml(rules, options);
}
