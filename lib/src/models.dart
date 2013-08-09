library nv.models;

import 'package:meta/meta.dart';
import 'package:observe/observe.dart';

import 'shared.dart';
import 'storage.dart';

class AppModel extends ChangeNotifierBase {
  static const _SEARCH_TERM = const Symbol('searchTerm');

  final Storage _storage;
  final ObservableList<Note> _notes;
  final ReadOnlyObservableList<Note> notes;

  String _searchTerm = '';

  factory AppModel(Storage storage) {
    var notes = new ObservableList<Note>();
    var roNotes = new ReadOnlyObservableList<Note>(notes);

    return new AppModel._internal(storage, notes, roNotes);
  }

  AppModel._internal(this._storage, this._notes, this.notes);

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

class TextContent extends Content {
  final String value;

  TextContent(this.value) {
    assert(value != null);
  }
}
