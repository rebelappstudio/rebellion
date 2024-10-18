import 'package:equatable/equatable.dart';

/// Class containing parsed @-key data: description, placeholders, examples etc
///
/// "@myKey": {
///   "description": "Key description",
///   "placeholders":
class AtKeyMeta with EquatableMixin {
  /// 'description' field of the @-key
  final String? description;

  /// List of placeholders for the @-key
  final List<AtKeyPlaceholder> placeholders;

  /// Default constructor
  const AtKeyMeta({
    required this.description,
    required this.placeholders,
  });

  /// Default empty constructor
  factory AtKeyMeta.empty() => const AtKeyMeta(
        description: null,
        placeholders: [],
      );

  /// Copy the object with new values
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
  /// Placeholder name
  final String? name;

  /// Placeholder type
  final String? type;

  /// Placeholder example
  final String? example;

  /// Default constructor
  const AtKeyPlaceholder({
    required this.name,
    required this.type,
    required this.example,
  });

  /// Copy the object with new values
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
