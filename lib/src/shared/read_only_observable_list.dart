part of nv.shared;

// TODO: throw better errors when mutation operation is attempted

class ReadOnlyObservableList<E> extends ListBase<E> implements Observable {
  final ObservableList<E> _list;

  ReadOnlyObservableList(this._list) {
    assert(_list != null);
  }

  int get length => _list.length;

  E operator [](int index) => _list[index];

  Stream<List<ChangeRecord>> get changes => _list.changes;

  bool deliverChanges() => _list.deliverChanges();

  void notifyChange(ChangeRecord record) => _list.notifyChange(record);

  bool get hasObservers => _list.hasObservers;
}
