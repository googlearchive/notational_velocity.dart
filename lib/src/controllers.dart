library nv.controllers;

import 'dart:async';
import 'package:observe/observe.dart';

import 'config.dart';
import 'models.dart';
import 'shared.dart';
import 'sync.dart';

// TODO: trim trailing whitespace from titles?
// TODO: prevent titles with tabs and newlines?
// TODO: prevent whitespace-only titles?

class AppController extends ChangeNotifierBase {
  static const _SEARCH_TERM = const Symbol('searchTerm');

  final MapSync<Note> _noteSync;
  final ObservableList<Note> _notes;
  final ReadOnlyObservableList<Note> notes;

  String _searchTerm = '';

  factory AppController(MapSync<Note> noteStorage) {
    var notes = new ObservableList<Note>();
    var roNotes = new ReadOnlyObservableList<Note>(notes);

    return new AppController._internal(noteStorage, notes, roNotes);
  }

  AppController._internal(this._noteSync, this._notes, this.notes) {
    assert(_noteSync.isLoaded);

    if(_noteStorage.isEmpty) {
      INITIAL_NOTES.forEach((String title, String content) {
        _noteStorage[title.toLowerCase()] = new Note.now(title, new TextContent(content));
      });
    }

    // TODO: hold onto the subscription. Support dispose?
    _noteSync.changes.listen(_onNoteSyncChanged);

    _updateNotesList();
  }

  //
  // Properties
  //

  String get searchTerm => _searchTerm;

  void set searchTerm(String value) {
    _searchTerm = value;
    _notifyChange(_SEARCH_TERM);
  }

  bool get isUpdated => _noteSync.isUpdated;

  //
  // Methods
  //

  Note openOrCreateNote(String title) {

    var key = title.toLowerCase();

    var value = _noteStorage[key];

    if(value == null) {
      var nc = new TextContent('');
      var note = new Note.now(title, nc);
      _noteStorage[note.key] = note;

      _updateNotesList();

      return note;
    }

    return value;
  }

  Future deleteNote(String title) {
    throw new UnimplementedError('not there yet...');
  }

  Note updateNote(String title, NoteContent noteContent) {
    // NOTE: title must *exactly* match an existing note
    // This keeps us honest about our search model, etc

    var note = new Note.now(title, noteContent);

    if(!_noteStorage.containsKey(note.key)) {
      throw new NVError('Provided title does not match existing note: ${note.title}');
    }

    _noteStorage[note.key] = note;

    _updateNotesList();

    return note;
  }

  //
  // Implementation
  //

  Map<String, Note> get _noteStorage => _noteSync.map;

  void _onNoteSyncChanged(List<ChangeRecord> records) {
    var forwardProps = records
        .where((ChangeRecord cr) => cr is PropertyChangeRecord)
        .map((pcr) => pcr.field)
        .where((Symbol field) => _NOTE_SYNC_FORWARD_PROPS.contains(field))
        .toList();

    for(var matchField in forwardProps) {
      _notifyChange(matchField);
    }
  }

  void _updateNotesList() {
    var sortedNotes = _noteStorage.values.toList()
        ..sort(_currentNoteSort);

    _notes.clear();
    _notes.addAll(sortedNotes);
  }

  static int _currentNoteSort(Note a, Note b) {
    // NOET: key => case insensitive sort
    return a.key.compareTo(b.key);
  }

  void _notifyChange(Symbol prop) {
    notifyChange(new PropertyChangeRecord(prop));
  }

  static const _NOTE_SYNC_FORWARD_PROPS = const [const Symbol('isUpdated')];
}
