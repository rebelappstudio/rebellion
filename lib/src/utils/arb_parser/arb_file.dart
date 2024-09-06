import 'package:equatable/equatable.dart';

class ArbFile with EquatableMixin {
  final String filepath;
  final String locale;
  final bool isMainFile;

  const ArbFile({
    required this.filepath,
    required this.locale,
    required this.isMainFile,
  });

  @override
  List<Object?> get props => [filepath, locale, isMainFile];
}
