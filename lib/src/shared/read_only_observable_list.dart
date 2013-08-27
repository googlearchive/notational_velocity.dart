part of nv.shared;

class ReadOnlyObservableList<E> extends ListBase<E>
  with ChangeNotifierMixin, _UnmodifiableListMixin<E>
  implements ObservableList<E> {

  final ObservableList<E> _list;

  ReadOnlyObservableList(this._list) {
    assert(_list != null);
    _list.changes.listen(_list_changes);
  }

  int get length => _list.length;

  E operator [](int index) => _list[index];

  void _list_changes(List<ChangeRecord> changes) {
    changes.forEach(notifyChange);
  }
}
