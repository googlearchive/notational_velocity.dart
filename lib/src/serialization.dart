library nv.serialization;

import 'dart:convert';
import 'package:meta/meta.dart';
import 'models.dart';

const _currentSerialVersion = 0;

const _TITLE = 'title', _LAST_MODIFIED = 'lastModified', _CONTENT = 'content',
  _VERSION = 'version';

const NOTE_CODEC = const NoteCodec();

class NoteCodec extends Codec<Note, Object> {
  const NoteCodec();

  Converter<Note, Object> get encoder => const _NoteToJsonConverter();

  Converter<Object, Note> get decoder => const _JsonToNoteConverter();
}

class _NoteToJsonConverter extends Converter<Note, Object> {
  const _NoteToJsonConverter();

  @override
  Object convert(Note note) => _toJson(note);
}

class _JsonToNoteConverter extends Converter<Object, Note> {
  const _JsonToNoteConverter();

  @override
  Note convert(Object json) => _fromJson(json);
}

Note _fromJson(dynamic json) {
  Map<String, dynamic> map = json;

  assert(json[_VERSION] == _currentSerialVersion);

  var lastModified = DateTime.parse(json[_LAST_MODIFIED]);
  var content = json[_CONTENT];

  return new Note(json[_TITLE], lastModified, content);
}

dynamic _toJson(Note note) {
  var map = new Map<String, dynamic>();

  map[_VERSION] = _currentSerialVersion;
  map[_TITLE] = note.title;
  map[_LAST_MODIFIED] = note.lastModified.toString();
  map[_CONTENT] = note.content;

  return map;
}
