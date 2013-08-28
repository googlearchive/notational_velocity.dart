part of nv.shared;

class CollectionView<E> extends ListBase<E>
  with ChangeNotifierMixin, _UnmodifiableListMixin<E>
  implements ObservableList<E> {

  final ObservableList<E> _list;
  List<E> _view;

  Predicate<E> _filter = null;
  Sorter<E> _sorter = null;

  CollectionView(this._list) {
    assert(_list != null);
    _list.changes.listen(_list_changes);
  }

  int get length => _items.length;

  E operator [](int index) => _items[index];

  Predicate<E> get filter => _filter;

  void set filter(Predicate<E> value) {
    if(value != _filter) {
      _filter = value;
      _dirty();
    }
  }

  Sorter<E> get sorter => _sorter;

  void set sorter(Sorter<E> value) {
    if(value != _sorter) {
      _sorter = value;
      _dirty();
    }
  }

  //
  // Implementation
  //

  Predicate<int> get _effectivefilter {
    return (_filter == null) ? (E foo) => true : _filter;
  }

  List<E> get _items {
    if(_isDirty) {
      assert(_view == null);
      _view = _list.where(_effectivefilter).toList();
      if(_sorter != null) {
        _view.sort(_sorter);
      }
    }

    assert(!_isDirty);
    if(_view == null) {
      return _list;
    } else {
      return _view;
    }
  }

  bool get _hasSortOrFilter => _filter != null || _sorter != null;

  bool get _isDirty => _hasSortOrFilter && _view == null;

  void _dirty() {
    _view = null;
    // raise gratuitus prop change here...I guess
  }

  void _list_changes(List<ChangeRecord> changes) {
    if(_hasSortOrFilter) {
      _dirty();
    } else {
      changes.forEach(notifyChange);
    }
  }
}
