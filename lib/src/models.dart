library nv.models;

import 'package:meta/meta.dart';
import 'package:observe/observe.dart';

class AppModel extends ChangeNotifierBase {
  static const _SEARCH_TERM = const Symbol('searchTerm');

  String _searchTerm = '';

  String get searchTerm => _searchTerm;

  void set searchTerm(String value) {
    _searchTerm = value;
    _notifyChange(_SEARCH_TERM);
  }

  void _notifyChange(Symbol prop) {
    notifyChange(new PropertyChangeRecord(prop));
  }
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
