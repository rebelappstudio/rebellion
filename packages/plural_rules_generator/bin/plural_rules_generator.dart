import 'package:plural_rules_generator/plural_rules_generator.dart';

Future<void> main(List<String> arguments) async {
  final filepath = arguments.first;
  await downloadAndGeneratePluralRules(filepath);
}
