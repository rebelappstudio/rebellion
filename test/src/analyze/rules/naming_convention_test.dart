import 'package:rebellion/src/analyze/analyzer_options.dart';
import 'package:rebellion/src/analyze/rules/naming_convention.dart';
import 'package:rebellion/src/utils/rebellion_options.dart';
import 'package:test/test.dart';

import '../../../infrastructure/app_tester.dart';
import '../../../infrastructure/logger.dart';
import '../../../infrastructure/test_arb_files.dart';

void main() {
  test('NamingConventionCheck checks key naming', () async {
    AppTester.create();

    final analyzerOptions = AnalyzerOptions(
      rebellionOptions: RebellionOptions.empty().copyWith(
        namingConvention: NamingConvention.camel,
      ),
      isSingleFile: true,
      containsMainFile: true,
    );

    var issues = NamingConventionRule().run(
      [
        createFile(
          values: {
            'key': 'value',
            'camelCaseKey': 'value',
          },
        ),
      ],
      analyzerOptions,
    );
    expect(issues, 0);
    expect(inMemoryLogger.output, isEmpty);

    inMemoryLogger.clear();
    issues = NamingConventionRule().run(
      [
        createFile(
          values: {
            'key': 'value',
            'snake_case_key': 'value',
            'kebab-case-key': 'value',
          },
        ),
      ],
      analyzerOptions,
    );
    expect(issues, 2);
    expect(
      inMemoryLogger.output,
      '''
filepath: key "snake_case_key" does not match selected naming convention (camel case)
filepath: key "kebab-case-key" does not match selected naming convention (camel case)
'''
          .trim(),
    );
  });

  test('Regexp checks case', () {
    expect(NamingConvention.camel.hasMatch('camel'), isTrue);
    expect(NamingConvention.camel.hasMatch('camelCase'), isTrue);
    expect(NamingConvention.camel.hasMatch('camelCaseCheck'), isTrue);
    expect(NamingConvention.camel.hasMatch('c'), isTrue);
    expect(NamingConvention.camel.hasMatch('snake_case'), isFalse);
    expect(NamingConvention.camel.hasMatch('kebab-case'), isFalse);
    expect(NamingConvention.camel.hasMatch('camelCase_not'), isFalse);
    expect(NamingConvention.camel.hasMatch('NotCamelCase'), isFalse);
    expect(NamingConvention.camel.hasMatch('camelCase2'), isTrue);
    expect(NamingConvention.camel.hasMatch('camelCase123'), isTrue);
    expect(NamingConvention.camel.hasMatch('camel2case'), isTrue);
    expect(NamingConvention.camel.hasMatch('camel2Case'), isTrue);
    expect(NamingConvention.camel.hasMatch('notACamelCase'), isFalse);

    expect(NamingConvention.snake.hasMatch('snake'), isTrue);
    expect(NamingConvention.snake.hasMatch('snake_case'), isTrue);
    expect(NamingConvention.snake.hasMatch('snake_case_check'), isTrue);
    expect(NamingConvention.snake.hasMatch('s'), isTrue);
    expect(NamingConvention.snake.hasMatch('camelCase'), isFalse);
    expect(NamingConvention.snake.hasMatch('kebab-case'), isFalse);
    expect(NamingConvention.snake.hasMatch('snake_caseNot'), isFalse);
    expect(NamingConvention.snake.hasMatch('NotSnake_case'), isFalse);
  });
}
