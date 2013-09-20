part of nv.controllers;

// TODO: trim trailing whitespace from titles?
// TODO: prevent titles with tabs and newlines?
// TODO: prevent whitespace-only titles?

class AppController extends ChangeNotifierBase {
  static const String _RUN_COUNT_KEY = 'runCount';
  static const String _NOTE_NAMESPACE = 'notes';

  final NoteList _notes;
  final CollectionView<NoteViewModel> _cv;
  final SelectionManager<NoteViewModel> notes;
  final EventHandle _searchResetHandle = new EventHandle();

  String _searchTerm = '';

  factory AppController(NoteList notes) {

    var cv = new CollectionView<NoteViewModel>(notes);
    var sm = new SelectionManager<NoteViewModel>(cv);

    return new AppController._core(notes, cv, sm);
  }

  AppController._core(this._notes, this._cv, this.notes) {
    _cv.sorter = _currentNoteSort;
  }

  static Future<AppController> init(Storage storage) {
    int runCount = null;
    return _initRunCount(storage)
        .then((int value) {
          runCount = value;
          assert(runCount >= 0);

          var nested = new NestedStorage(storage, _NOTE_NAMESPACE);

          return _initNoteList(nested, runCount == 0);
        })
        .then((NoteList list) {
          return new AppController(list);
        });
  }

  //
  // Properties
  //

  String get searchTerm => _searchTerm;

  void set searchTerm(String value) {
    value = (value == null) ? '' : value;
    if(value != _searchTerm) {
      _searchTerm = value;
      _cv.filter = _filterNote;
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

  Future<Note> openOrCreate() {
    if(notes.hasSelection) {
      return new Future<Note>.value(notes.selectedValue);
    }

    var newTitle = (_searchTerm.isEmpty) ? 'Untitled Note' : _searchTerm;

    var newNote = _notes.create(newTitle);

    return new Future(() {
      notes.selectedValue = newNote;
      assert(notes.hasSelection);
      return newNote;
    });
  }

  bool updateSelectedNoteContent(String newContent) {
    _log('updateSelectedNoteContent with: $newContent');

    assert(notes.hasSelection);

    var currentContent = notes.selectedValue.content;
    if(currentContent == newContent) return false;

    notes.selectedValue.content = newContent;
    return true;
  }

  //
  // Implementation
  //

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

  static Future<int> _initRunCount(Storage storage) {
    return storage.get(_RUN_COUNT_KEY)
        .then((int runCount) {
          if(runCount == null) {
            runCount = 0;
          } else {
            assert(runCount >= 0);
            runCount++;
          }
          return storage.set(_RUN_COUNT_KEY, runCount)
              .then((_) => runCount);
        });
  }

  static Future<NoteList> _initNoteList(Storage storage, bool firstRun) {
    return NoteList.init(storage)
        .then((NoteList nl) {
          if(firstRun) {
            assert(nl.isEmpty);
            return _initialPopulateNoteList(nl);
          } else {
            return nl;
          }
        });
  }

  static Future<NoteList> _initialPopulateNoteList(NoteList list) {
    assert(list.isEmpty);
    return Future
        .forEach(config.INITIAL_NOTES.keys, (String key) {
          var nvm = list.create(key);
          nvm.content = config.INITIAL_NOTES[key];
          return nvm.whenUpdated;
        })
        .then((_) => list);
  }
}
