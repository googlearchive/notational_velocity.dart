part of nv.shared;

/**
 * Provides a view over a source [ObservableList].
 *
 * Exposes change notifications.
 *
 * Does not allow modification of underlying data.
 */
class ObservableListView<E> extends _UnmodifiableListBase<E> {

  final ObservableList<E> _list;

  ObservableListView(this._list) {
    assert(_list != null);
    print("OLV: ctor $hashCode");
    printStack();
    _list.changes.listen(_list_changes);
  }

  int get length => _list.length;

  E operator [](int index) => _list[index];

  void _list_changes(List<ChangeRecord> changes) {
    print("OLV: got changes from parent - $hashCode");
    changes.forEach(notifyChange);
  }

  bool deliverChanges() {
    print('OLV: delivering changes! - $hashCode');

    var superDone = super.deliverChanges();
    print('OLV: done delivering changes - $superDone');
    return superDone;
  }
}
