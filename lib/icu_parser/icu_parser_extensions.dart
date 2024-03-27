import 'package:petitparser/petitparser.dart';
import 'package:rebellion/icu_parser/icu_parser.dart';
import 'package:rebellion/icu_parser/message_format.dart';

/// Custom code on top of the original IcuParser simply to keep IcuParser as is
/// so future updates are easier
extension IcuParserX on IcuParser {
  /// Whether [message] is likely to contain a plural. Likely means that plural
  /// may contain keys not supported by intl. E.g. 'million{{count} books}'
  void likelyContainsPlural(String message) {
    return;
    final parsed = (compound | intlPlural | any())
        .map((result) =>
            List<BaseElement>.from(result is List ? result : [result]))
        .parse(message);
    final foo = parsed is Success ? parsed.value : null;
    print(foo);

    if (foo is PluralElement) {
      print((foo as PluralElement).options.join(', '));
    }
  }
}
