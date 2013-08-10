library nv.models;

import 'dart:async';
import 'package:meta/meta.dart';
import 'package:observe/observe.dart';

import 'shared.dart';
import 'storage.dart';

part 'models/app_model.dart';

class Note {
  final String title;
  final NoteContent content;

  Note(this.title, this.content) {
    assert(title != null);
    assert(content != null);
  }

  // TODO: hashcode and ==

  @override
  String toString() => 'Note: $title';
}

abstract class NoteContent {

  dynamic toJson();

}

class TextContent extends NoteContent {
  final String value;

  TextContent(this.value) {
    assert(value != null);
  }

  dynamic toJson() => value;

  bool operator ==(other) =>
      other is TextContent && other.value == this.value;

  int get hashCode => value.hashCode;

  String toString() =>
      (value.length > 30) ? "${value.substring(0, 27)}..." : value;

  static const _MAX_TO_STRING_LENGTH = 30;
}

/**
 * Assume [value] is a valid JSON-able object
 */
NoteContent _parse(dynamic value) {
  assert(value != null);

  if(value is String) {
    // TextContent
    return new TextContent(value);
  } else {
    throw new ArgumentError("Don't know how to turn value into NoteContent");
  }
}
