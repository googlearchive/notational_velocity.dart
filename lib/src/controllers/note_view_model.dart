part of nv.controllers;

class NoteViewModel extends ChangeNotifierBase
  with ComparableMixin<NoteViewModel> implements Note {

  final KUID id;

  final BackgroundUpdate<Note> _update;

  NoteViewModel._(this.id, this._update);

  Future get whenUpdated => _update.updatedValue.then((_) => null);

  //
  // Note
  //

  String get title => _update.value.title;

  DateTime get lastModified => _update.value.lastModified;

  String get key => _update.value.key;

  String get content => _update.value.content;

  //
  // Note - end
  //

}


// all keys are GUIDs

class NoteList extends ListBase<NoteViewModel> implements Observable {
  final Storage _storage;
  final ObservableSet<NoteViewModel> _items;

  NoteList._(this._storage, this._items) {
    assert(_storage != null);
    assert(_items != null);
  }

  static Future<NoteList> init(Storage store) => _load(store)
      .then((Set<NoteViewModel> set) {
        return new NoteList._(store, new ObservableSet.from(set));
      });

  NoteViewModel create(String title) {

    var note = new Note.now(title, '');
    var id = new KUID.next();

    var update = new BackgroundUpdate.withNew((val) => _update(id, val), note);

    var nvm = new NoteViewModel._(id, update);

    _items.add(nvm);

    return nvm;
  }

  //
  // Observable
  //

  Stream<List<ChangeRecord>> get changes => _items.changes;

  void notifyChange(ChangeRecord record) => _items.notifyChange(record);

  bool get hasObservers => _items.hasObservers;

  bool deliverChanges() => _items.deliverChanges();

  //
  // Observable - End
  //

  //
  // List
  //

  int get length => _items.length;

  //
  // List - End
  //

  Future _update(KUID id, Note value) {
    var idString = id.toString();
    var noteJson = NOTE_CODEC.encode(value);
    return _storage.set(idString, noteJson);
  }

  static Future<Set<NoteViewModel>> _load(Storage storage) {
    return storage.getKeys()
        .then((List<String> keys) {
          var uuids = keys.map((String key) => new KUID.parse(key))
              .toList(growable: false);

          var set = new Set<NoteViewModel>();
          return Future.forEach(uuids, (KUID id) {

          })
          .then((_) {
            assert(set.length == uuids.length);
            return set;
          });
        });

  }
}
