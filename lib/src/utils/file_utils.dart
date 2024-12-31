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

/// Get list of all .arb files except the main file
/// Returns list of tuples (Target language, ARB filename)
List<ArbFile> getArbFiles(List<String> filesAndFolders, String mainLocale) {
  final files = _getAllFiles(filesAndFolders);
  return files
      .map((file) {
        final locale = getLocaleFromFilepath(file.path);
        if (locale == null) return null;

        return ArbFile(
          filepath: file.path,
          locale: locale,
          isMainFile: locale == mainLocale,
        );
      })
      .nonNulls
      .toList();
}

/// Parse ARB file name and extract locale
///
/// E.g. "strings_fi.arb" returns "fi"
String? getLocaleFromFilepath(String filepath) {
  final extension = path.extension(filepath);
  if (extension.toLowerCase() != '.arb') return null;

  final filename = path.basenameWithoutExtension(filepath);

  // Ignore diff files
  if (filename.endsWith('_diff')) return null;

  final codes = filename
      .split('_')
      .where((e) => e.length == 2)
      .toList()
      .reversed
      .toList();
  final String locale;
  if (codes.length == 2) {
    locale = codes[1];
  } else if (codes.length == 1) {
    locale = codes[0];
  } else {
    logError('Cannot parse locale from $filepath');
    throw Exception("Filename can't be parsed");
  }

  return locale;
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

/// Get a list of requested files
List<ParsedArbFile> getFilesAndFolders(
  RebellionOptions options,
  ArgResults? argResults,
) {
  final mainLocale = options.mainLocale;
  final filesAndFolders = argResults?.rest ?? const [];
  ensureFilesAndFoldersExist(filesAndFolders);

  return getArbFiles(filesAndFolders, mainLocale).map(parseArbFile).toList();
}

/// Write [content] to the file with the given [filename]
void writeArbFile(Map<String, dynamic> content, String filename) {
  final encoder = JsonEncoder.withIndent('  ');
  final jsonContent = encoder.convert(content);
  final file = fileReader.file(filename);
  file.writeAsStringSync(jsonContent);
}

/// Ensure that all specified files and folders exist or throw an exception
@visibleForTesting
void ensureFilesAndFoldersExist(List<String> filesAndFolders) {
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
