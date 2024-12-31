import 'package:equatable/equatable.dart';
import 'package:rebellion/src/analyze/rules/rule.dart';

/// Class containing parsed @-key data: description, placeholders, examples etc
///
/// "@myKey": {
///   "description": "Key description",
///   "placeholders":
///     ...
///
/// Individual keys may ignore certain rules. For example, all_caps rule is
/// ignored for this key:
///
/// "myKey": "X",
/// "@myKey": {
///   "@@x-ignore": "all_caps",
/// }
class AtKeyMeta with EquatableMixin {
  /// 'description' field of the @-key
  final String? description;

  /// List of placeholders for the @-key
  final List<AtKeyPlaceholder> placeholders;

  /// Raw list if rules that should be ignored by the linter
  final List<String> ignoredRulesRaw;

  /// List of [RuleKey]s that should be ignored by the linter
  final List<RuleKey> ignoredRules;

  /// Default constructor
  AtKeyMeta({
    required this.description,
    required this.placeholders,
    required this.ignoredRulesRaw,
  }) : ignoredRules = ignoredRulesRaw.map(RuleKey.fromKey).nonNulls.toList();

  /// Default empty constructor
  factory AtKeyMeta.empty() => AtKeyMeta(
        description: null,
        placeholders: [],
        ignoredRulesRaw: [],
      );

  /// Copy the object with new values
  AtKeyMeta copyWith({
    String? description,
    List<AtKeyPlaceholder>? placeholders,
    List<String>? ignoredRulesRaw,
  }) {
    return AtKeyMeta(
      description: description ?? this.description,
      placeholders: placeholders ?? this.placeholders,
      ignoredRulesRaw: ignoredRulesRaw ?? this.ignoredRulesRaw,
    );
  }

  /// Return true if [rule] is in the list of ignored rules for this key
  bool isRuleIgnored(RuleKey rule) {
    return ignoredRules.contains(rule);
  }

  // coverage:ignore-start
  @override
  List<Object?> get props => [description, placeholders, ignoredRulesRaw];
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
    List<String>? ignoredRules,
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
