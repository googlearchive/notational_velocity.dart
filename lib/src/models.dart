library nv.models;

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

}

class TextContent extends NoteContent {
  final String value;

  TextContent(this.value) {
    assert(value != null);
  }
}
