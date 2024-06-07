import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

const _supportedPlurals = ['zero', 'one', 'two', 'few', 'many', 'other'];
const _pluralsXml =
    'https://raw.githubusercontent.com/unicode-org/cldr/main/common/supplemental/plurals.xml';
const _temporaryFileLocation = './plurals.xml';
const _outputFileLocation = './lib/generated/plural_rules.dart';

typedef PluralRules = Map<String, List<String>>;

/// Download Unicode CLDR plural rules, parse it and create a Dart file with
/// plural rules for future use.
///
/// Source for plural rules is the official Unicode repository:
/// https://github.com/unicode-org/cldr
Future<void> main() async {
  final file = await downloadFile();
  print('File downloaded successfully');

  final rules = await extractRules(file);
  print('Rules extracted successfully');

  await generateDartCode(rules);
  print('Dart code generated successfully');

  file.delete();
  Process.run('dart', ['format', _outputFileLocation]);
  print('Done');
}

Future<File> downloadFile() async {
  final response = await http.get(Uri.parse(_pluralsXml));

  if (response.statusCode == 200) {
    final file = File(_temporaryFileLocation);
    await file.writeAsBytes(response.bodyBytes);
    return file;
  } else {
    throw Exception(
      'Failed to download file. Status code: ${response.statusCode}',
    );
  }
}

Future<PluralRules> extractRules(File file) async {
  final lines = await file.readAsString();

  final xml = XmlDocument.parse(lines);

  final plurals = xml.getElement('supplementalData')?.getElement('plurals');
  if (plurals == null) {
    throw Exception('Failed to parse plurals');
  }

  final PluralRules result = {};
  for (final node in plurals.children) {
    final attributes =
        node.attributes.firstWhereOrNull((e) => e.name.local == 'locales');
    if (attributes == null) continue;

    final locales = attributes.value.split(' ');
    if (locales.isEmpty) continue;

    final List<String> cases = [];
    for (final plural in node.children) {
      final pluralCase = plural.attributes
          .firstWhereOrNull((e) => e.name.local == 'count')
          ?.value;
      if (pluralCase == null) continue;
      if (!_supportedPlurals.contains(pluralCase)) {
        throw Exception('Unknown plural case: $pluralCase');
      }

      cases.add(pluralCase);
    }

    for (final locale in locales) {
      result[locale] = cases;
    }
  }

  return result;
}

Future<void> generateDartCode(PluralRules rules) {
  final map = jsonEncode(rules);
  final code = '''
/// Generated file. Do not edit.
class PluralRules {
  static const Map<String, List<String>> _rules = $map;

  List<String> operator [](String locale) => _rules[locale] ?? [];
}
''';

  final outputFile = File(_outputFileLocation);
  return outputFile.writeAsString(code);
}
