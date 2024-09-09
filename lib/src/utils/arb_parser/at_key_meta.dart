import 'package:equatable/equatable.dart';

/// Class containing parsed @-key data: description, placeholders, examples etc
///
/// "@myKey": {
///   "description": "Key description",
///   "placeholders":
class AtKeyMeta with EquatableMixin {
  final String? description;
  final List<AtKeyPlaceholder> placeholders;

  const AtKeyMeta({
    required this.description,
    required this.placeholders,
  });

  factory AtKeyMeta.empty() => const AtKeyMeta(
        description: null,
        placeholders: [],
      );

  AtKeyMeta copyWith({
    String? description,
    List<AtKeyPlaceholder>? placeholders,
  }) {
    return AtKeyMeta(
      description: description ?? this.description,
      placeholders: placeholders ?? this.placeholders,
    );
  }

  // coverage:ignore-start
  @override
  List<Object?> get props => [description, placeholders];
// coverage:ignore-end
}

/// One ARB placeholder. E.g.
/// "placeholders": {
///   "count": {
///     "type": "int",
///     "example": "42"
///   },
class AtKeyPlaceholder with EquatableMixin {
  final String? name;
  final String? type;
  final String? example;

  const AtKeyPlaceholder({
    required this.name,
    required this.type,
    required this.example,
  });

  AtKeyPlaceholder copyWith({
    String? name,
    String? type,
    String? example,
  }) {
    return AtKeyPlaceholder(
      name: name ?? this.name,
      type: type ?? this.type,
      example: example ?? this.example,
    );
  }

  // coverage:ignore-start
  @override
  List<Object?> get props => [name, type, example];
  // coverage:ignore-end
}
