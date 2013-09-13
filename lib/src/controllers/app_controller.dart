part of nv.controllers;

// TODO: trim trailing whitespace from titles?
// TODO: prevent titles with tabs and newlines?
// TODO: prevent whitespace-only titles?

class AppController extends ChangeNotifierBase {

  final MapSync<Note> _noteSync;
  final ObservableList<Note> _notes;
  final CollectionView<Note> _cv;
  final SelectionManager<Note> notes;
  final EventHandle _searchResetHandle = new EventHandle();

  String _searchTerm = '';

  factory AppController(MapSync<Note> noteSync) {

    var notes = new ObservableList<Note>();
    var cv = new CollectionView<Note>(notes);
    var sm = new SelectionManager<Note>(cv);

    return new AppController._core(noteSync, notes, cv, sm);
  }

  AppController._core(this._noteSync, this._notes, this._cv, this.notes) {
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
      _notifyPropChange(const Symbol('searchTerm'));
    }
  }

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

    notes.selectedValue = value;

    return value;
  }

  void updateSelectedNoteContent(String newContent) {
    _log('updateSelectedNoteContent');

    assert(notes.hasSelection);

    var textContent = new TextContent(newContent);

    var note = new Note.now(notes.selectedValue.title, textContent);

    if(!_noteStorage.containsKey(note.key)) {
      throw new NVError('Provided title does not match existing note: ${note.title}');
    }

    _noteStorage[note.key] = note;

    _dirtyNoteList();

    notes.selectedValue = note;
  }

  //
  // Implementation
  //

  void _dirtyNoteList() {

    var expectedNotes = _noteStorage.values.toList(growable: true);
    _notes.removeWhere((note) => !expectedNotes.contains(note));
    expectedNotes.removeWhere((note) => _notes.contains(note));

    _notes.addAll(expectedNotes);
  }

  Map<String, Note> get _noteStorage => _noteSync.map;

  void _onNoteSyncIsUpdated(PropertyChangeRecord record) {
    _notifyPropChange(const Symbol('isUpdated'));
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

  void _notifyPropChange(Symbol prop) {
    notifyChange(new PropertyChangeRecord(prop));
  }
}
