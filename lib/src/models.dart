library nv.models;

import 'dart:async';
import 'package:bot/bot.dart';
import 'package:meta/meta.dart';
import 'package:observe/observe.dart';

import 'serialization.dart' as serial;
import 'shared.dart';
import 'storage.dart';

part 'models/app_model.dart';

class Note {
  final String title;
  final NoteContent content;
  final DateTime lastModified;

  Note(this.title, this.lastModified, this.content) {
    assert(title != null);
    assert(content != null);
    assert(lastModified != null);
  }

  factory Note.now(String title, NoteContent content) =>
      new Note(title, new DateTime.now(), content);

  factory Note.fromJson(dynamic json) => serial.fromJson(json);

  @override
  bool operator ==(other) =>
      other is Note &&
      other.title == title &&
      other.content == content &&
      other.lastModified == lastModified;

  int get hashCode => Util.getHashCode([title, content, lastModified]);

  @override
  String toString() => 'Note: $title';

  dynamic toJson() => serial.toJson(this);
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
