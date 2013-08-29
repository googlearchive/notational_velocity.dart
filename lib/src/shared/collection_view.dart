part of nv.shared;

class CollectionView<E> extends _UnmodifiableListBase<E> {

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
    _filter = value;
    _dirty(true);
  }

  Sorter<E> get sorter => _sorter;

  void set sorter(Sorter<E> value) {
    _sorter = value;
    _dirty(false);
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

  void _dirty(changesLength) {
    _view = null;
    notifyChange(new ListChangeRecord(0, removedCount: _list.length,
        addedCount: _list.length));
    if(changesLength) {
      notifyChange(new PropertyChangeRecord(const Symbol('length')));
    }
  }

  void _list_changes(List<ChangeRecord> changes) {
    if(_hasSortOrFilter) {
      _dirty(true);
    } else {
      changes.forEach(notifyChange);
    }
  }
}
