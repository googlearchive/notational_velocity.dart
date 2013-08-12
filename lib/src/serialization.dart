library nv.serialization;

import 'dart:convert';
import 'models.dart';

const _currentSerialVersion = 0;

const _TITLE = 'title', _LAST_MODIFIED = 'lastModified', _CONTENT = 'content',
  _VERSION = 'version';

const _n2j = const _NoteToJsonConverter();
const _j2n = const _JsonToNoteConverter();

const NOTE_CODEC = const NoteCodec();

class NoteCodec extends Codec<Note, Object> {
  const NoteCodec();

  Converter<Note, Object> get encoder => _n2j;

  Converter<Object, Note> get decoder => _j2n;
}

class _NoteToJsonConverter extends Converter<Note, Object> {
  const _NoteToJsonConverter();

  Object convert(Note note) => _toJson(note);
}

class _JsonToNoteConverter extends Converter<Object, Note> {
  const _JsonToNoteConverter();

  Note convert(Object json) => _fromJson(json);
}

Note _fromJson(dynamic json) {
  Map<String, dynamic> map = json;

  assert(json[_VERSION] == _currentSerialVersion);

  var lastModified = DateTime.parse(json[_LAST_MODIFIED]);
  var content = _noteContentFromJson(json[_CONTENT]);

  return new Note(json[_TITLE], lastModified, content);
}

dynamic _toJson(Note note) {
  var map = new Map<String, dynamic>();

  map[_VERSION] = _currentSerialVersion;
  map[_TITLE] = note.title;
  map[_LAST_MODIFIED] = note.lastModified.toString();
  map[_CONTENT] = _jsonFromNoteContent(note.content);

  return map;
}

dynamic _jsonFromNoteContent(NoteContent content) {
  if(content is TextContent) {
    return content.value;
  } else {
    throw new UnimplementedError('cannot the provided NoteContent');
  }
}

NoteContent _noteContentFromJson(dynamic json) {
  if(json is String) {
    return new TextContent(json);
  } else {
    throw new UnimplementedError('cannot create NoteContent from the provided value');
  }
}
