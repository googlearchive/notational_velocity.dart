part of nv.shared;

class SelectionManager<E> extends MappedListView<E, Selectable<E>> {
  ObservableList<E> get source => super._source;

  E _selectedItem;
  int _selectedIndex = -1;

  SelectionManager(ObservableList<E> source) :
    super(source, (e) => new Selectable<E>._(e));

  E get selectedItem => _selectedItem;

  void set selectedItem(E value) {
    var index = _source.indexOf(value);

  }

  int get selectedIndex => _selectedIndex;

  void set selectedIndex(int index) {
    if(index != null) {
      assert(index >= 0);
      assert(index < source.length);
    }

  }

  bool get hasSelection => _selectedIndex >= 0;
}

class Selectable<E> extends ChangeNotifierBase {
  final E value;

  bool _isSelected = false;

  Selectable._(this.value);

  bool get isSelected => _isSelected;

}
