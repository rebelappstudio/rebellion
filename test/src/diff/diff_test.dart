import 'package:rebellion/src/utils/command_runner.dart';
import 'package:test/test.dart';

import '../../infrastructure/app_tester.dart';
import '../../infrastructure/logger.dart';

void main() {
  test('Diff finds no missing translations', () async {
    final tester = AppTester.create();
    tester.populateFileSystem({
      'intl_en.arb': '''{
        "key1":"value",
        "key2":"value",
        "key3":"value"
      }''',
      'intl_es.arb': '''{
        "key1":"valor",
        "key2":"valor",
        "key3":"valor"
      }''',
    });

    await commandRunner.run(['diff', '.']);
    expect(inMemoryLogger.output, 'No missing translations found');
  });

  test('Diff finds missing translations across multiple files', () async {
    final tester = AppTester.create();
    tester.populateFileSystem({
      'intl_en.arb': '''{
        "key1":"value",
        "key2":"value",
        "key3":"value"
      }''',
      'intl_es.arb': '''{
        "key1":"valor",
        "key2":"valor"
      }''',
      'intl_fr.arb': '''{
      }''',
    });

    await commandRunner.run(['diff', '.']);
    expect(
        inMemoryLogger.output,
        '''
./intl_es.arb: 1 missing translations:
 - key3
./intl_fr.arb: 3 missing translations:
 - key1
 - key2
 - key3
'''
            .trim());
  });

  test('Missing translations are written to diff files', () async {
    final tester = AppTester.create();
    tester.populateFileSystem({
      'intl_en.arb': '''{
        "key1":"value",
        "key2":"value",
        "key3":"value"
      }''',
      'intl_es.arb': '''{
        "key1":"valor",
        "key2":"valor"
      }''',
      'intl_fr.arb': '''{
      }''',
    });

    await commandRunner.run(['diff', '.', '--output', 'file']);
    expect(inMemoryLogger.output, isEmpty);
    expect(
        tester.getFileContent('intl_es_diff.arb'),
        '''
{
  "key3": ""
}
'''
            .trim());
    expect(
        tester.getFileContent('intl_fr_diff.arb'),
        '''
{
  "key1": "",
  "key2": "",
  "key3": ""
}
'''
            .trim());
  });
}
