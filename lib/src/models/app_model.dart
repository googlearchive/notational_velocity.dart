part of nv.models;

// TODO: trim trailing whitespace from titles?
// TODO: prevent titles with tabs and newlines?
// TODO: prevent whitespace-only titles?

class AppModel extends ChangeNotifierBase {
  static const _SEARCH_TERM = const Symbol('searchTerm');

  final Storage _noteStorage;
  final ObservableList<Note> _notes;
  final ReadOnlyObservableList<Note> notes;

  String _searchTerm = '';

  factory AppModel(Storage storage) {
    var notes = new ObservableList<Note>();
    var roNotes = new ReadOnlyObservableList<Note>(notes);

    // nesting storage to avoid collisions w/ other apps on this domain
    var nested = new NestedStorage(storage, 'nv0.0.1');

    return new AppModel._internal(nested, notes, roNotes);
  }

  AppModel._internal(Storage storage, this._notes, this.notes) :
    _noteStorage = new NestedStorage(storage, 'notes');

  //
  // Properties
  //

  String get searchTerm => _searchTerm;

  void set searchTerm(String value) {
    _searchTerm = value;
    _notifyChange(_SEARCH_TERM);
  }

  //
  // Methods
  //

  Future<Note> openOrCreateNote(String title) {

    return _searchTitle(title)
        .then((String matchedTitle) {

          if(matchedTitle == null) {
            return _createSaveReturnNote(title);
          } else {
            return _getNote(matchedTitle)
                .then((Note nc) {
                  // Should absolutely get a valid value here
                  assert(nc != null);
                  return nc;
                });
          }
        });
  }

  Future deleteNote(String title) {
    throw new UnimplementedError('not there yet...');
  }

  Future updateNote(String title, NoteContent content) {
    // NOTE: title must *exactly* match an existing note
    // This keeps us honest about our search model, etc

    var note = new Note.now(title, content);

    return _noteStorage.exists(title)
        .then((bool exists) {
          if(!exists) {
            throw new NVError('Provided title does not match existing note: $title');
          }

          return _noteStorage.set(title, note.toJson());
        });
  }

  //
  // Implementation
  //

  /**
   * Returns null if not fonud
   */
  Future<Note> _getNote(String title) {
    return _noteStorage.get(title)
        .then((dynamic value) {
          if(value == null) return null;

          return new Note.fromJson(value);
        });
  }

  Future<Note> _createSaveReturnNote(String title) {
    // TODO: assume the title is not taken? Hmm...

    var nc = new TextContent('');
    var note = new Note(title, new DateTime.now(), nc);

    return _noteStorage.set(title, note.toJson())
        .then((_) => note);
  }

  Future<String> _searchTitle(String title) {
    assert(title != null);
    // TODO: should support ordering by title and last modified
    // for now: alpha order desc by title

    title = title.toLowerCase();

    return _noteStorage.getKeys()
        .then((List<String> keys) {
          keys.sort();

          return keys.firstWhere((t) => t.toLowerCase().startsWith(title), orElse: () => null);
        });
  }

  void _notifyChange(Symbol prop) {
    notifyChange(new PropertyChangeRecord(prop));
  }
}
