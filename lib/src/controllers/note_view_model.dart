part of nv.controllers;

class NoteViewModel extends ChangeNotifierBase
  with ComparableMixin<NoteViewModel> implements Note {

  final KUID _id;

  final BackgroundUpdate<Note> _update;



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
