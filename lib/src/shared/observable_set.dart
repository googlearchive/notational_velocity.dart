part of nv.shared;

/**
 * A set which keeps its items ordered
 *
 * ...and exposes an observable list.
 */
class ObservableSet<E extends Comparable<E>> extends IterableBase<E>
  implements Set<E> {

  final ObservableList<E> _sorted;
  final ObservableListView<E> view;

  factory ObservableSet() => new ObservableSet.from([]);

  factory ObservableSet.from(Iterable<E> other){
    var set = new Set.from(other);

    var sortedList = set.toList()
        ..sort();

    var sorted = new ObservableList.from(sortedList);

    return new ObservableSet._(sorted);
  }

  ObservableSet._(ObservableList<E> sorted) :
    this._sorted = sorted,
    this.view = new ObservableListView(sorted);

  Iterator<E> get iterator => _sorted.iterator;

  void clear() => _sorted.clear();

  void removeAll(Iterable<Object> elements) {
    for(var e in elements) {
      _sorted.remove(e);
    }
  }

  void addAll(Iterable<E> elements) {
    for(var e in elements) {
      this.add(e);
    }
  }

  // TODO: binary insert? O(ln) is better than O(n)
  void add(E element) {
    for(int i = 0; i < _sorted.length; i++) {
      var compare = element.compareTo(_sorted[i]);
      if(compare < 0) {
        _sorted.insert(i, element);
        return;
      } else if(compare == 0) {
        assert(element == _sorted[i]);
        // NOOP!
        return;
      }
    }
    _sorted.add(element);
  }


  bool remove(Object element) => _sorted.remove(element);
}
