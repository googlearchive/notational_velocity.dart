part of nv.controllers;

// TODO: trim trailing whitespace from titles?
// TODO: prevent titles with tabs and newlines?
// TODO: prevent whitespace-only titles?

class AppController extends ChangeNotifierBase {

  final MapSync<Note> _noteSync;
  final ObservableList<NoteController> _notes;
  final ReadOnlyObservableList<NoteController> notes;
  final EventHandle _searchResetHandle = new EventHandle();

  String _searchTerm = '';
  bool _noteListDirty = false;
  Note _selectedNote = null;

  factory AppController(MapSync<Note> noteStorage) {
    var notes = new ObservableList<NoteController>();
    var roNotes = new ReadOnlyObservableList<NoteController>(notes);

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

  Note get selectedNote => _selectedNote;

  bool get noteSelected => _selectedNote != null;

  bool get hasNotes => notes.isNotEmpty;

  String get searchTerm => _searchTerm;

  void set searchTerm(String value) {
    value = (value == null) ? '' : value;
    if(value != _searchTerm) {
      _searchTerm = value;
      _dirtyNoteList();
      _notifyChange(const Symbol('searchTerm'));
    }
  }

  bool get isUpdated => !_noteListDirty && _noteSync.isUpdated;

  Stream get onSearchReset => _searchResetHandle.stream;

  //
  // Methods
  //

  void resetSearch() {
    // TODO: update selected note!

    searchTerm = '';
    _searchResetHandle.add(EventArgs.empty);
  }

  Note openOrCreate() {

    var key = searchTerm.toLowerCase();

    var value = _noteStorage[key];

    if(value == null) {
      var nc = new TextContent('');
      value = new Note.now(searchTerm, nc);
      _noteStorage[value.key] = value;

      _dirtyNoteList();
    }

    _selectedNote = value;

    _dirtyNoteList();

    return value;
  }

  void updateSelectedNoteContent(String newContent) {
    assert(_selectedNote != null);

    var textContent = new TextContent(newContent);

    var note = new Note.now(_selectedNote.title, textContent);

    if(!_noteStorage.containsKey(note.key)) {
      throw new NVError('Provided title does not match existing note: ${note.title}');
    }

    _selectedNote = _noteStorage[note.key] = note;

    _dirtyNoteList();
  }

  //
  // Implementation
  //

  void _requestSelect(NoteController nc) {
    if(nc.note != _selectedNote) {
      assert(_notes.contains(nc));

      if(_selectedNote != null) {
        // NOTE: the current selected note SHOULD be represented in the filter
        var currentSelectedNoteController =
            _notes.singleWhere((nc) => nc.note == _selectedNote);
        currentSelectedNoteController._updateIsSelected(false);
        _selectedNote = null;
      }

      _selectedNote = nc.note;
      nc._updateIsSelected(true);
      _notifyChange(const Symbol('selectedNote'));
      _notifyChange(const Symbol('noteSelected'));
    }
  }

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

    var foundSelected = false;

    var sortedNotes = _noteStorage.values
        .where(_filterNote)
        .map((Note n) {
          var nc = new NoteController(n, this);
          if(nc.isSelected) {
            assert(!foundSelected);
            foundSelected = true;
          }

          return nc;
        })
        .toList()
        ..sort(_currentNoteSort);

    _notes.clear();
    _notes.addAll(sortedNotes);

    if(_selectedNote != null && !foundSelected) {
      _selectedNote = null;
      _notifyChange(const Symbol('selectedNote'));
      _notifyChange(const Symbol('noteSelected'));
    }

    // just making darn sure I haven't messed anything up here by re-dirtying
    // the list during update
    assert(!_noteListDirty);
    _notifyChange(const Symbol('isUpdated'));
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
