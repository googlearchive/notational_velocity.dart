part of nv.shared;

/**
 * Provides a view over a source [ObservableList].
 *
 * Exposes change notifications.
 *
 * Does not allow modification of underlying data.
 */
class ObservableListView<E> extends _UnmodifiableListBase<E>
  with ChangeNotifierMixin implements ObservableList<E> {

  final ObservableList<E> _list;

  ObservableListView(this._list) {
    assert(_list != null);
    _list.changes.listen(_list_changes);
  }

  int get length => _list.length;

  E operator [](int index) => _list[index];

  void _list_changes(List<ChangeRecord> changes) {
    changes.forEach(notifyChange);
  }
}
