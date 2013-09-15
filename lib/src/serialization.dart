library nv.serialization;

import 'dart:convert';
import 'models.dart';

const _currentSerialVersion = 0;

const _TITLE = 'title', _LAST_MODIFIED = 'lastModified', _CONTENT = 'content',
  _VERSION = 'version';

// TODO: would love these to be const: https://codereview.chromium.org/22979003/
final _n2j = new _NoteToJsonConverter();
final _j2n = new _JsonToNoteConverter();

const NOTE_CODEC = const NoteCodec();

class NoteCodec extends Codec<Note, Object> {
  const NoteCodec();

  Converter<Note, Object> get encoder => _n2j;

  Converter<Object, Note> get decoder => _j2n;
}

class _NoteToJsonConverter extends Converter<Note, Object> {
  Object convert(Note note) => _toJson(note);
}

class _JsonToNoteConverter extends Converter<Object, Note> {
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
