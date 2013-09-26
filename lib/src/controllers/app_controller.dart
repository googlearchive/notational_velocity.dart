part of nv.controllers;

// TODO: trim trailing whitespace from titles?
// TODO: prevent titles with tabs and newlines?
// TODO: prevent whitespace-only titles?

class AppController extends ChangeNotifierBase {
  static const String _RUN_COUNT_KEY = 'runCount';
  static const String _NOTE_NAMESPACE = 'notes';

  final int runCount;
  final NoteList _notes;
  final CollectionView<NoteViewModel> _cv;
  final SelectionManager<NoteViewModel> notes;
  final EventHandle _searchResetHandle = new EventHandle();

  String _searchTerm = '';

  factory AppController(int runCount, NoteList notes) {

    var cv = new CollectionView<NoteViewModel>(notes);
    var sm = new SelectionManager<NoteViewModel>(cv);

    return new AppController._core(runCount, notes, cv, sm);
  }

  AppController._core(this.runCount, this._notes, this._cv, this.notes) {
    assert(runCount >= 0);
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
          return new AppController(runCount, list);
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

      var filterMatch = _cv.firstWhere(_filterMatchNote, orElse: () => null);
      notes.selectedValue = filterMatch;
      assert(notes.hasSelection == (filterMatch != null));

      _notifyPropChange(const Symbol('searchTerm'));
    }
  }

  Stream get onSearchReset => _searchResetHandle.stream;

  //
  // Methods
  //

  void resetSearch() {
    notes.selectedIndex = -1;
    searchTerm = '';

    // paranoid
    assert(notes.length == _notes.length);
    assert(!notes.hasSelection);
    assert(notes.every((Selectable s) => !s.isSelected));

    _searchResetHandle.add(EventArgs.empty);
  }

  Future<Note> openOrCreate() {
    if(notes.hasSelection) {
      return new Future<Note>.value(notes.selectedValue);
    }

    var newTitle = (_searchTerm.isEmpty) ? 'Untitled Note' : _searchTerm;

    var newNote = _notes.create(newTitle);

    return new Future(() {
      assert(notes.source.contains(newNote));
      notes.selectedValue = newNote;
      assert(notes.hasSelection);
      assert(identical(notes.selectedValue, newNote));
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

  void moveSelectionUp() => _moveSelection(true);

  void moveSelectionDown() => _moveSelection(false);

  //
  // Implementation
  //

  void _moveSelection(bool up) {
    if(notes.isEmpty) return;

    var newIndex = notes.selectedIndex + (up ? -1 : 1);

    if(newIndex == -2) {
      // up from no selection, should select the last element
      newIndex = notes.length - 1;
    } else if(newIndex == -1) {
      // up from first item, just stay at first item
      newIndex = 0;
    } else if(newIndex == notes.length) {
      // down from last item, stay at last item
      newIndex = notes.length -1;
    }

    notes.selectedIndex = newIndex;
  }

  /**
   * returns true if the Note should be SELECTED given the current _searchTerm
   */
  bool _filterMatchNote(Note instance) {
    if(_searchTerm.isEmpty) return false;

    var selected =  instance.title.toLowerCase()
        .startsWith(_searchTerm.toLowerCase());

    // if the item is selected, it should match the filter, too
    assert(!selected || _filterNote(instance));

    return selected;
  }

  /**
   * returns true if the Note should be FILTERED given the current _searchTerm
   */
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
