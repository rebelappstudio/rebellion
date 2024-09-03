import 'dart:io';

import 'package:json_events/json_events.dart';
import 'package:path/path.dart' as path;

import 'package:rebellion/utils/file_utils.dart';
import 'package:rebellion/utils/logger.dart';

/// Get all strings from [filename] file
ParsedArbFile parseArbFile(ArbFile file) {
  final filepath = path.join(file.filepath);
  final arbContent = File(filepath).readAsStringSync();

  // All ARB keys including at-keys and duplicated keys
  final rawKeys = <String>[];

  final List<JsonEvent> jsonEvents;
  try {
    /// Inexplicit check: ARB file is a valid JSON file
    jsonEvents = JsonEventDecoder().convert(arbContent);
  } on FormatException {
    logError('${file.filepath}: file content is not a valid JSON');
    rethrow;
  }

  final content = <String, dynamic>{};
  String? keyName;
  String? atKeyName;
  String? placeholderName;
  String? placeholderKeyName;
  String? keyValue;

  AtKeyMeta? atKeyMeta;
  AtKeyPlaceholder? placeholder;

  int level = 0;
  for (final e in jsonEvents) {
    switch (e.type) {
      case JsonEventType.beginArray:
      case JsonEventType.endArray:
      case JsonEventType.arrayElement:
        logError('${file.filepath}: ARB files must not contain arrays');
        exit(1);
      case JsonEventType.beginObject:
        level++;

        // @-key begins
        if (level == 2) {
          atKeyMeta = AtKeyMeta.empty();
        }

        // Placeholder begins
        if (level == 4) {
          placeholder = AtKeyPlaceholder(
            name: placeholderName,
            type: null,
            example: null,
          );
        }
      case JsonEventType.endObject:
        level--;

        // @-key ends
        if (level == 1 && atKeyMeta != null) {
          content[keyName!] = atKeyMeta;
          keyName = null;
          atKeyMeta = null;
        }

        // Placeholder ends
        if (level == 3 && placeholder != null) {
          atKeyMeta = atKeyMeta?.copyWith(
            placeholders: [...atKeyMeta.placeholders, placeholder],
          );
          placeholder = null;
          placeholderName = null;
          placeholderKeyName = null;
        }

      case JsonEventType.propertyName:
        // Regular key name (text, plurals etc)
        if (level == 1) {
          keyName = e.value;
          if (keyName == null) continue;
          rawKeys.add(keyName);
        }

        // @-key name
        if (level == 2) {
          if (e.value == 'description' || e.value == 'placeholders') {
            atKeyName = e.value;
          }
        }

        // Placeholder name. This name is set when placeholder object is created
        if (level == 3) {
          placeholderName = e.value;
        }

        // Placeholder key value
        if (level == 4) {
          placeholderKeyName = e.value;
        }

      case JsonEventType.propertyValue:
        // Regular key value
        if (level == 1) {
          keyValue = e.value;
          if (keyName == null) {
            keyValue = null;
            continue;
          }
          content[keyName] = keyValue;
        }

        // @-key value
        if (level == 2) {
          if (atKeyName == 'description') {
            atKeyMeta = atKeyMeta?.copyWith(description: e.value);
          }
        }

        // Placeholders
        if (level == 4) {
          if (placeholderKeyName == 'type') {
            placeholder = placeholder?.copyWith(type: e.value);
          } else if (placeholderKeyName == 'example') {
            placeholder = placeholder?.copyWith(example: e.value);
          }
        }
    }
  }

  return ParsedArbFile(
    file: file,
    content: content,
    rawKeys: rawKeys,
  );
}

/// Class containing parsed @-key data: description, placeholders, examples etc
///
/// "@myKey": {
///   "description": "Key description",
///   "placeholders":
class AtKeyMeta {
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

  @override
  String toString() =>
      'AtKeyMeta(description: $description, placeholders: $placeholders)';
}

/// One ARB placeholder. E.g.
/// "placeholders": {
///   "count": {
///     "type": "int",
///     "example": "42"
///   },
class AtKeyPlaceholder {
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

  @override
  String toString() =>
      'AtKeyPlaceholder(name: $name, type: $type, example: $example)';
}