part of nv.shared;

typedef bool Matcher<S, T>(S source, T target);
typedef T Mapper<S, T>(S source);

/*
 * Well, hmm. So this impl will do an okay job of not calling mapper too often
 * but we're paying the hash lookup cost on every indexer access
 *
 * So...we could throw memory at it...or get more clever
 * ...but this works for now
 */

class MappedListView<S, T> extends ChangeNotifierList<T> {

  final List<S> _source;
  final Matcher<S, T> _matcher;
  final Mapper<S, T> _mapper;

  final Map<S, T> _cache = new Map<S, T>();
  bool _isDirty = true;

  MappedListView(this._source, this._matcher, this._mapper) {
    assert(_source != null);
    (_source as Observable).changes.listen(_list_changes);
  }

  int get length => _source.length;

  T operator[](int index) {
    var sourceValue = _source[index];
    return _cache.putIfAbsent(sourceValue, () => _mapper(sourceValue));
  }

  //
  // Implementation
  //

  void _list_changes(List<ChangeRecord> changes) {
    var listChanges = changes
        .where((cr) => cr is ListChangeRecord)
        .toList();

    if(listChanges.isNotEmpty) {
      ListChangeRecord change = listChanges.single;
      if(change.removedCount > 0) {
        // TODO: in theory, we could be more careful here, but for now
        _cache.clear();
      }
    }

    changes.forEach(notifyChange);
  }
}
