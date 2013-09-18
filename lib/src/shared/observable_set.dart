part of nv.shared;

/**
 * A set which keeps its items ordered
 *
 * ...and exposes an observable list.
 */
class ObservableSet<E extends Comparable<E>> extends ListBase<E>
  implements Observable, Set<E> {

  final ObservableList<E> _sorted;

  factory ObservableSet() => new ObservableSet.from([]);

  factory ObservableSet.from(Iterable<E> other){
    var set = new Set.from(other);

    var sortedList = set.toList()
        ..sort();

    var sorted = new ObservableList.from(sortedList);

    return new ObservableSet._(sorted);
  }

  ObservableSet._(ObservableList<E> sorted) :
    this._sorted = sorted;

  //
  // Observable
  //

  Stream<List<ChangeRecord>> get changes => _sorted.changes;

  void notifyChange(ChangeRecord record) => _sorted.notifyChange(record);

  bool get hasObservers => _sorted.hasObservers;

  bool deliverChanges() => _sorted.deliverChanges();

  //
  // Set
  //
  Set<E> difference(Set<E> other) {
    throw new UnimplementedError();
  }

  Set<E> intersection(Set<E> other) {
    throw new UnimplementedError();
  }

  Set<E> union(Set<E> other) {
    throw new UnimplementedError();
  }

  //
  // List
  //

  int get length => _sorted.length;

  Iterator<E> get iterator => _sorted.iterator;

  E operator[](int index) => _sorted[index];

  void clear() => _sorted.clear();

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
