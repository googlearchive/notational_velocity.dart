part of nv.shared;

typedef bool Matcher<S, T>(S source, T target);
typedef T Mapper<S, T>(S source);

// TODO: RECYCLE Items!
// TODO: Be smart about minimal changes

class MappedListView<S, T> extends _UnmodifiableListBase<T> {

  final ObservableList<S> _source;
  final Matcher<S, T> _matcher;
  final Mapper<S, T> _mapper;

  List<T> _content;
  bool _isDirty = true;

  MappedListView(this._source, this._matcher, this._mapper) {
    assert(_source != null);
    _source.changes.listen(_list_changes);
  }

  int get length => _view.length;

  T operator[](int index) => _view[index];

  //
  // Implementation
  //

  List<T> get _view {
    if(_isDirty) {
      _content = _source.map(_mapper).toList(growable: false);
      _isDirty = false;
    }
    return _content;
  }

  void _list_changes(List<ChangeRecord> changes) {
    _isDirty = true;
    changes.forEach(notifyChange);
  }
}
