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

/// Filename of the configuration YAML file
@visibleForTesting
const configFilename = 'rebellion_options.yaml';

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

  if (!_supportedLocales.contains(locale)) {
    logError('$filepath: locale $locale is not supported by Flutter');
    throw Exception('Locale not supported');
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

/// Load options from the YAML file
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

// List of locales supported by Flutter
// https://github.com/flutter/flutter/blob/ce318b7b539e228b806f81b3fa7b33793c2a2685/packages/flutter_tools/lib/src/localizations/gen_l10n_types.dart
final Set<String> _supportedLocales = <String>{
  'aa',
  'ab',
  'ae',
  'af',
  'ak',
  'am',
  'an',
  'ar',
  'as',
  'av',
  'ay',
  'az',
  'ba',
  'be',
  'bg',
  'bh',
  'bi',
  'bm',
  'bn',
  'bo',
  'br',
  'bs',
  'ca',
  'ce',
  'ch',
  'co',
  'cr',
  'cs',
  'cu',
  'cv',
  'cy',
  'da',
  'de',
  'dv',
  'dz',
  'ee',
  'el',
  'en',
  'eo',
  'es',
  'et',
  'eu',
  'fa',
  'ff',
  'fi',
  'fil',
  'fj',
  'fo',
  'fr',
  'fy',
  'ga',
  'gd',
  'gl',
  'gn',
  'gsw',
  'gu',
  'gv',
  'ha',
  'he',
  'hi',
  'ho',
  'hr',
  'ht',
  'hu',
  'hy',
  'hz',
  'ia',
  'id',
  'ie',
  'ig',
  'ii',
  'ik',
  'io',
  'is',
  'it',
  'iu',
  'ja',
  'jv',
  'ka',
  'kg',
  'ki',
  'kj',
  'kk',
  'kl',
  'km',
  'kn',
  'ko',
  'kr',
  'ks',
  'ku',
  'kv',
  'kw',
  'ky',
  'la',
  'lb',
  'lg',
  'li',
  'ln',
  'lo',
  'lt',
  'lu',
  'lv',
  'mg',
  'mh',
  'mi',
  'mk',
  'ml',
  'mn',
  'mr',
  'ms',
  'mt',
  'my',
  'na',
  'nb',
  'nd',
  'ne',
  'ng',
  'nl',
  'nn',
  'no',
  'nr',
  'nv',
  'ny',
  'oc',
  'oj',
  'om',
  'or',
  'os',
  'pa',
  'pi',
  'pl',
  'ps',
  'pt',
  'qu',
  'rm',
  'rn',
  'ro',
  'ru',
  'rw',
  'sa',
  'sc',
  'sd',
  'se',
  'sg',
  'si',
  'sk',
  'sl',
  'sm',
  'sn',
  'so',
  'sq',
  'sr',
  'ss',
  'st',
  'su',
  'sv',
  'sw',
  'ta',
  'te',
  'tg',
  'th',
  'ti',
  'tk',
  'tl',
  'tn',
  'to',
  'tr',
  'ts',
  'tt',
  'tw',
  'ty',
  'ug',
  'uk',
  'ur',
  'uz',
  've',
  'vi',
  'vo',
  'wa',
  'wo',
  'xh',
  'yi',
  'yo',
  'za',
  'zh',
  'zu',
};
