library nv.serialization;

import 'models.dart';

const _currentSerialVersion = 0;

const _TITLE = 'title', _LAST_MODIFIED = 'lastModified', _CONTENT = 'content',
  _VERSION = 'version';

Note fromJson(dynamic json) {
  Map<String, dynamic> map = json;

  assert(json[_VERSION] == _currentSerialVersion);

  var lastModified = DateTime.parse(json[_LAST_MODIFIED]);
  var content = _noteContentFromJson(json[_CONTENT]);

  return new Note(json[_TITLE], lastModified, content);
}

dynamic toJson(Note note) {
  var map = new Map<String, dynamic>();

  map[_VERSION] = _currentSerialVersion;
  map[_TITLE] = note.title;
  map[_LAST_MODIFIED] = note.lastModified.toString();
  map[_CONTENT] = note.content.toJson();

  return map;
}

NoteContent _noteContentFromJson(dynamic json) {
  if(json is String) {
    return new TextContent(json);
  } else {
    throw new UnimplementedError('cannot create NoteContent from the provided value');
  }
}
