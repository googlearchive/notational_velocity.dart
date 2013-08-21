library nv.controllers;

import 'dart:async';
import 'package:bot/bot.dart';
import 'package:observe/observe.dart';

import 'config.dart';
import 'models.dart';
import 'shared.dart';
import 'sync.dart';

// TODO: trim trailing whitespace from titles?
// TODO: prevent titles with tabs and newlines?
// TODO: prevent whitespace-only titles?

class AppController extends ChangeNotifierBase {

  final MapSync<Note> _noteSync;
  final ObservableList<Note> _notes;
  final ReadOnlyObservableList<Note> notes;
  final EventHandle _searchResetHandle = new EventHandle();

  String _searchTerm = '';
  bool _noteListDirty = false;

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
    filterPropertyChangeRecords(_noteSync, const Symbol('isUpdated'))
      .listen(_onNoteSyncIsUpdated);

    _dirtyNoteList();
  }

  //
  // Properties
  //

  String get searchTerm => _searchTerm;

  void set searchTerm(String value) {
    value = (value == null) ? '' : value;
    if(value != _searchTerm) {
      _searchTerm = value;
      _dirtyNoteList();
      _notifyChange(const Symbol('searchTerm'));
    }
  }

  bool get isUpdated => _noteSync.isUpdated;

  Stream get onSearchReset => _searchResetHandle.stream;

  //
  // Methods
  //

  void resetSearch() {
    searchTerm = '';
    _searchResetHandle.add(EventArgs.empty);
  }

  Note openOrCreateNote(String title) {

    var key = title.toLowerCase();

    var value = _noteStorage[key];

    if(value == null) {
      var nc = new TextContent('');
      var note = new Note.now(title, nc);
      _noteStorage[note.key] = note;

      _dirtyNoteList();

      return note;
    }

    return value;
  }

  Note updateNote(String title, NoteContent noteContent) {
    // NOTE: title must *exactly* match an existing note
    // This keeps us honest about our search model, etc

    var note = new Note.now(title, noteContent);

    if(!_noteStorage.containsKey(note.key)) {
      throw new NVError('Provided title does not match existing note: ${note.title}');
    }

    _noteStorage[note.key] = note;

    _dirtyNoteList();

    return note;
  }

  //
  // Implementation
  //

  Map<String, Note> get _noteStorage => _noteSync.map;

  void _onNoteSyncIsUpdated(PropertyChangeRecord record) {
    _notifyChange(const Symbol('isUpdated'));
  }

  void _dirtyNoteList() {
    if(!_noteListDirty) {
      _noteListDirty = true;
      Timer.run(_updateNoteList);
    }
  }

  void _updateNoteList() {
    _noteListDirty = false;

    var sortedNotes = _noteStorage.values
        .where(_filterNote)
        .toList()
        ..sort(_currentNoteSort);

    _notes.clear();
    _notes.addAll(sortedNotes);

    // just making darn sure I haven't messed anything up here by re-dirtying
    // the list during update
    assert(!_noteListDirty);
  }

  bool _filterNote(Note instance) {
    assert(searchTerm != null);

    if(searchTerm.isEmpty) {
      return true;
    } else {
      var term = searchTerm.trim().toLowerCase();
      return instance.title.toLowerCase().contains(term);
    }
  }

  // TODO: at some point, use user selected sort order, so this stays
  //       an instance method
  int _currentNoteSort(Note a, Note b) {
    // NOET: key => case insensitive sort
    return a.key.compareTo(b.key);
  }

  void _notifyChange(Symbol prop) {
    notifyChange(new PropertyChangeRecord(prop));
  }
}
