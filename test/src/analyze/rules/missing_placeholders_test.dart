import 'package:rebellion/src/analyze/analyzer_options.dart';
import 'package:rebellion/src/analyze/rules/missing_placeholders.dart';
import 'package:rebellion/src/utils/command_runner.dart';
import 'package:rebellion/src/utils/exit_exception.dart';
import 'package:rebellion/src/utils/rebellion_options.dart';
import 'package:test/test.dart';

import '../../../infrastructure/app_tester.dart';
import '../../../infrastructure/logger.dart';
import '../../../infrastructure/test_arb_files.dart';

void main() {
  late AppTester tester;

  setUp(() {
    tester = AppTester.create();

    // Enable MissingPlaceholders rule and set main locale
    tester.setConfigFile('''
rules:
  - missing_placeholders

options:
  main_locale: en
''');
  });

  test('Reports no issues when placeholders are present', () async {
    tester.populateFileSystem({
      'intl_en.arb': '''{
  "nameTitle": "Hello {name}",
  "@nameTitle": {
    "placeholders": {
      "name": {
        "type": "String"
      }
    }
  }
}''',
      'intl_fi.arb': '''{
  "nameTitle": "¡Hola, {name}!"
}''',
    });

    await commandRunner.run(['analyze', '.']);
    expect(inMemoryLogger.output, 'No issues found');
  });

  test("Ignores @-keys that can't be parsed", () async {
    final issues = MissingPlaceholders().run(
      [
        createFile(
          filepath: 'intl_en.arb',
          isMainFile: true,
          locale: 'en',
          values: {
            'key': 'Hello, {name}!',
            '@key': 'foo',
          },
        ),
        createFile(
          filepath: 'intl_es.arb',
          isMainFile: false,
          locale: 'es',
          values: {'key': '¡Hola, {name}!'},
        ),
      ],
      AnalyzerOptions(
        rebellionOptions: RebellionOptions.empty(),
        isSingleFile: true,
        containsMainFile: true,
      ),
    );
    expect(issues, isZero);
    expect(inMemoryLogger.output, isEmpty);
  });

  test(
      "Reports errors when placeholder are different from what's in the main file",
      () async {
    tester.populateFileSystem({
      'int_en.arb': '''{
  "key": "Hello, {name}!",
  "@key": {
    "placeholders": {
      "name": {
        "type": "String"
      }
    }
  }
}''',
      'intl_es.arb': '''{
  "key": "¡Hola, {nombre}!"
}''',
    });

    expect(
      () async => await commandRunner.run(['analyze', '.']),
      throwsA(isA<ExitException>()),
    );
    expect(
      inMemoryLogger.output,
      '''
./intl_es.arb: key "key" is missing a placeholder defined in the main file: name
./intl_es.arb: key "key" uses a placeholder not present in the main file: nombre

2 issues found
'''
          .trim(),
    );
  });

  test('Reports placeholders without name', () {
    tester.populateFileSystem({
      'intl_en.arb': '''{
  "key": "Hello, {name}!",
  "@key": {
    "placeholders": [
      {
        "name": null,
        "type": "String",
        "example": null
      }
    ]
  }
}''',
      'intl_es.arb': '''{
"key": "¡Hola, {name}!"
}''',
    });

    expect(
      () async => await commandRunner.run(['analyze', '.']),
      throwsA(isA<ExitException>()),
    );
    expect(
      inMemoryLogger.output,
      '''
./intl_en.arb: key "@key" is missing placeholders definition

1 issue found
'''
          .trim(),
    );
  });

  test('Reports missing placeholder type', () {
    tester.populateFileSystem({
      'intl_en.arb': '''{
  "key": "Hello, {name}!",
  "@key": {
    "placeholders": {
      "name": {
      }
    }
  }
}''',
      'intl_es.arb': '''{
  "key": "¡Hola, {name}!"
}''',
    });

    expect(
      () async => await commandRunner.run(['analyze', '.']),
      throwsA(isA<ExitException>()),
    );
    expect(
      inMemoryLogger.output,
      '''
./intl_en.arb: key "@key" is missing a placeholder type for "name"

1 issue found
'''
          .trim(),
    );
  });

  test('Reports missing placeholders in plural strings', () {
    tester.populateFileSystem({
      'intl_en.arb': '''{
  "key": "{count, plural, one{1 item} other{{count} items}}",
  "@key": {
    "placeholders": {
      "count": {
        "type": "int"
      }
    }
  }
}''',
      'intl_es.arb': '''{
  "key": "{count, plural, one{1 item} other{many items}}"
}''',
    });
    expect(
      () async => await commandRunner.run(['analyze', '.']),
      throwsA(isA<ExitException>()),
    );
    expect(
      inMemoryLogger.output,
      '''
./intl_es.arb: key "key" is missing a placeholder defined in the main file: count

1 issue found
'''
          .trim(),
    );
  });

  test('Reports no issues when plurals are used without variable substitution',
      () async {
    tester.populateFileSystem({
      'intl_en.arb': '''{
  "key": "{count, plural, one{One item} other{Many items}}",
  "@key": {
    "placeholders": {
      "count": {
        "type": "int"
      }
    }
  }
}''',
      'intl_es.arb': '''{
  "key": "{count, plural, one{Uno elemento} other{Muchos elementos}}"
}''',
    });
    await commandRunner.run(['analyze', '.']);
    expect(inMemoryLogger.output, 'No issues found');
  });

  test('Reports missing placeholders in inline strings', () async {
    tester.populateFileSystem({
      'intl_en.arb': '''
{
  "key": "Selected items: {count, plural, one {1 item} other {{count} items}}. Continue?",
  "@key": {
    "placeholders": {
      "count": {
        "type": "int"
      }
    }
  }
}''',
      'intl_es.arb': '''
{
  "key": "{count, plural, one{1 elemento} other{{count} elementos}}. ¿Continuar?"
}
''',
    });
    await commandRunner.run(['analyze', '.']);
    expect(inMemoryLogger.output, 'No issues found');

    tester.populateFileSystem({
      'intl_en.arb': '''
{
  "key": "Selected items: {count, plural, one {1 item} other {{count} items}}. Continue?",
  "@key": {
    "placeholders": {
      "count": {
        "type": "int"
      }
    }
  }
}''',
      'intl_es.arb': '''
{
  "key": "{count, plural, one{1 elemento} other{Muchos elementos}}. ¿Continuar?"
}
''',
    });
    inMemoryLogger.clear();
    expect(
      () async => await commandRunner.run(['analyze', '.']),
      throwsA(isA<ExitException>()),
    );
    expect(
        inMemoryLogger.output,
        '''
./intl_es.arb: key "key" is missing a placeholder defined in the main file: count

1 issue found
'''
            .trim());
  });

  test(
      "Reports no missing placeholders if plural strings have extra placeholders",
      () async {
    tester.populateFileSystem({
      'intl_en.arb': '''
{
  "key": "{count, plural, zero{Mode is available} one{{count} games with {stars} remain} two{{count} games with {stars} remain} few{{count} games with {stars} remain} many{{count} games with {stars} remain} other{{count} games with {stars} remain}}",
  "@key": {
    "placeholders": {
      "count": {
        "type": "int"
      },
      "stars": {
        "type": "String"
      }
    }
  }
}
''',
      'intl_ru.arb': '''
{
  "key": "{count, plural, one{Осталась {count} игра и {stars} звезда} few{Остались {count} игры и {stars}} many{Осталось {count} игр и {stars}} other{Осталось {count} игр и {stars}}}"
}
''',
    });

    await commandRunner.run(['analyze', '.']);
    expect(inMemoryLogger.output, 'No issues found');
  });

  test("Placeholder is not defined and @-key is present in translation file",
      () async {
    tester.populateFileSystem({
      'intl_en.arb': '''
{
  "distanceMeters": "{distance} m",
  "@distanceMeters": {}
}
''',
      'intl_fi.arb': '''
{
  "distanceMeters": "{distance} m",
  "@distanceMeters": {}
}
''',
    });

    expect(
      () async => await commandRunner.run(['analyze', '.']),
      throwsA(isA<ExitException>()),
    );
    expect(
      inMemoryLogger.output,
      '''
./intl_en.arb: key "@distanceMeters" is missing placeholders definition

1 issue found
'''
          .trim(),
    );
  });

  test("@-key is present in translation file", () async {
    tester.populateFileSystem({
      'intl_en.arb': '''
{
  "distanceMeters": "{distance} m",
  "@distanceMeters": {
    "placeholders": {
      "distance": {
        "type": "int"
      }
    }
  }
}
''',
      'intl_fi.arb': '''
{
  "distanceMeters": "{distance} m",
  "@distanceMeters": {
    "placeholders": {
      "distance": {
        "type": "int"
      }
    }
  }
}
''',
    });

    await commandRunner.run(['analyze', '.']);
    expect(inMemoryLogger.output, 'No issues found');
  });

  test("Translation has placeholders not present in main file", () async {
    tester.populateFileSystem({
      'intl_en.arb': '''
{
  "nameTitle": "Hello {name} {surname}",
  "@nameTitle": {
    "placeholders": {
      "name": {
        "type": "String"
      }
    }
  }
}
''',
      'intl_fi.arb': '''
{
  "nameTitle": "Hei {name} {secondName} {surname}"
}
''',
    });

    expect(
      () async => await commandRunner.run(['analyze', '.']),
      throwsA(isA<ExitException>()),
    );
    expect(
        inMemoryLogger.output,
        '''
./intl_fi.arb: key "nameTitle" uses a placeholder not present in the main file: secondName

1 issue found
'''
            .trim());
  });

  test("Translation has missing placeholders only present in main file",
      () async {
    tester.populateFileSystem({
      'intl_en.arb': '''
{
  "nameTitle": "Hello {name} {surname}",
  "@nameTitle": {
    "placeholders": {
      "name": {
        "type": "String"
      }
    }
  }
}
''',
      'intl_fi.arb': '''
{
  "nameTitle": "Hei {name}"
}
''',
    });

    expect(
      () async => await commandRunner.run(['analyze', '.']),
      throwsA(isA<ExitException>()),
    );
    expect(
        inMemoryLogger.output,
        '''
./intl_fi.arb: key "nameTitle" is missing a placeholder defined in the main file: surname

1 issue found
'''
            .trim());
  });

  test("Main file key lacks placeholders definition", () async {
    tester.populateFileSystem({
      'intl_en.arb': '''
{
  "nameTitle": "Hello {name}",
  "@nameTitle": {
    "placeholders": {
      "name": {
        "type": "String"
      },
      "surname": {
        "type": "String"
      }
    }
  }
}
''',
    });

    expect(
      () async => await commandRunner.run(['analyze', '.']),
      throwsA(isA<ExitException>()),
    );
    expect(
        inMemoryLogger.output,
        '''
./intl_en.arb: key "@nameTitle" defines a placeholder that is not used in the string: surname

1 issue found
'''
            .trim());
  });
}
