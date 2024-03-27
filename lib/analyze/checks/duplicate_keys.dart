import 'package:rebellion/analyze/checks/check_base.dart';
import 'package:rebellion/icu_parser/icu_parser.dart';
import 'package:rebellion/utils/logger.dart';
import 'package:rebellion/utils/file_utils.dart';

/// Check for duplicated keys
class DuplicatedKeys extends CheckBase {
  const DuplicatedKeys()
      : super(
          optionName: 'duplicated-keys',
          defaultsTo: true,
        );

  @override
  int run(IcuParser parser, List<ParsedArbFile> files) {
    int issues = 0;

    for (final file in files) {
      final uniqueKeys = file.keys.toSet();
      final allKeys = [...file.rawKeys];

      for (final uniqueKey in uniqueKeys) {
        allKeys.remove(uniqueKey);
      }

      if (allKeys.isNotEmpty) {
        issues++;
        final duplicatesString = allKeys.map((e) => '"$e"').join(', ');
        logError(
          '${file.file.filepath}: file has duplicate keys: $duplicatesString',
        );
      }
    }

    return issues;
  }
}
