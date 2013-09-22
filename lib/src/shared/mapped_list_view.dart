part of nv.shared;

typedef T Mapper<S, T>(S source);

/*
 * Well, hmm. So this impl will do an okay job of not calling mapper too often
 * but we're paying the hash lookup cost on every indexer access
 *
 * So...we could throw memory at it...or get more clever
 * ...but this works for now
 */

abstract class _MappedListViewBase<S, T> extends ChangeNotifierList<T> {

  final List<S> _source;

  final Map<S, T> _cache = new Map<S, T>();
  bool _isDirty = true;

  _MappedListViewBase(this._source) {
    assert(_source != null);
    assert(_source is Observable);
    (_source as Observable).changes.listen(_list_changes);
  }

  int get length => _source.length;

  T operator[](int index) {
    var sourceValue = _source[index];
    return _cache.putIfAbsent(sourceValue, () => _wrap(index, sourceValue));
  }

  //
  // Implementation
  //

  /**
   * Like operator[], but returns null if the item isn't cached
   * Used by subclasses
   */
  T _getCachedValueAtIndex(int index) {
    var sourceValue = _source[index];
    return _cache[sourceValue];
  }

  T _wrap(int index, S value);

  void _list_changes(List<ChangeRecord> changes) {
    var anyRemoves = changes
        .where((cr) => cr is ListChangeRecord)
        .where((ListChangeRecord lcr) => lcr.removedCount > 0)
        .isNotEmpty;

    if(anyRemoves) {
      // TODO: could be a bit more efficient here, but at least it's correct
      var toRemove = new Set();
      for(var k in _cache.keys) {
        if(!_source.contains(k)) toRemove.add(k);
      }

      for(var k in toRemove) _cache.remove(k);
    }

    changes.forEach(notifyChange);
  }
}


class MappedListView<S, T> extends _MappedListViewBase<S, T> {

  final Mapper<S, T> _mapper;

  MappedListView(List<S> source, this._mapper) : super(source);

  //
  // Implementation
  //

  T _wrap(int index, T value) => _mapper(value);
}
