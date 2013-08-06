library nv.models;

import 'package:meta/meta.dart';
import 'package:observe/observe.dart';

class AppModel extends ObservableBase {
  @observable
  String searchTerm = 'world!';
}

class Note {
  final String title;
  final Content content;

  Note(this.title, this.content) {
    assert(title != null);
    assert(content != null);
  }

  // TODO: hashcode and ==

  @override
  String toString() => 'Note: $title';
}

abstract class Content {

}

class TextContent {
  final String value;

  TextContent(this.value) {
    assert(value != null);
  }

}
