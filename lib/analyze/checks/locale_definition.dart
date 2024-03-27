import 'package:rebellion/analyze/checks/check_base.dart';
import 'package:rebellion/icu_parser/icu_parser.dart';
import 'package:rebellion/utils/logger.dart';
import 'package:rebellion/utils/file_utils.dart';

/// Translation file contains @@locale key with locale definition
class LocaleDefinitionPresent extends CheckBase {
  const LocaleDefinitionPresent()
      : super(
          optionName: 'locale-definition',
          defaultsTo: true,
        );

  @override
  int run(IcuParser parser, List<ParsedArbFile> files) {
    int issues = 0;

    for (final file in files) {
      final keys = file.keys;
      if (!keys.contains('@@locale')) {
        issues++;
        logError('${file.file.filepath}: no @@locale key found');
      }
    }

    return issues;
  }
}
