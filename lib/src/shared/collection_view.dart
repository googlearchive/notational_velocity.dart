part of nv.shared;

class CollectionView<E> extends ListBase<E> implements Observable {

  final List<E> _source;
  final ObservableList<E> _view;

  Predicate<E> _filter = null;
  Sorter<E> _sorter = null;

  CollectionView(this._source) :
    _view = new ObservableList() {
    assert(_source != null);
    assert(_source is Observable);
     (_source as Observable).changes.listen(_list_changes);

     _update();
  }

  Predicate<E> get filter => _filter;

  void set filter(Predicate<E> value) {
    _filter = value;
    _update();
  }

  Sorter<E> get sorter => _sorter;

  void set sorter(Sorter<E> value) {
    _sorter = value;
    _update();
  }

  //
  // Observable
  //

  Stream<List<ChangeRecord>> get changes => _view.changes;

  void notifyChange(ChangeRecord record) => _view.notifyChange(record);

  bool get hasObservers => _view.hasObservers;

  bool deliverChanges() => _view.deliverChanges();

  //
  // List
  //

  int get length => _view.length;

  E operator [](int index) => _view[index];

  //
  // Implementation
  //

  bool _effectivefilter(E item) {
    return (_filter == null) ? true : _filter(item);
  }

  void _list_changes(List<ChangeRecord> changes) {
    _update();
  }

  void _update() {
    var theSet = _source.where(_effectivefilter).toList(growable: false);

    if(_sorter != null) {
      theSet.sort(_sorter);
    }

    for(var i = 0; i < theSet.length; i++) {
      var target = theSet[i];
      while(_view.length > i) {
        // see if target exists after [i] in _view
        var targetIndex = _view.indexOf(target, i);

        if(targetIndex == i) {
          // NOOP!
          break;
        } else if(targetIndex > i) {
          // remove it and add it back
          var item = _view.removeAt(targetIndex);
          assert(item == target);
          _view.insert(i, item);
          break;
        } else {
          assert(targetIndex == -1);
          _view.removeAt(i);
        }
      }
      if(_view.length <= i) {
        _view.add(target);
      }

      assert(_view[i] == target);
    }

    // now remove everything after
    if(_view.length > theSet.length) {
      _view.removeRange(theSet.length, _view.length);
    }
  }
}
