part of nv.shared;

class SelectionManager<E> extends MappedListView<E, Selectable<E>> {
  final ObservableList<E> source;

  E _selectedItem;
  int _selectedIndex;

  SelectionManager(ObservableList<E> source) :
    this.source = source,
    super(source, (e) => new Selectable<E>._(e));

  E get selectedItem => _selectedItem;

  int get selectedIndex => _selectedIndex;

  bool get hasSelection => _selectedIndex != null;
}

class Selectable<E> extends ChangeNotifierBase {
  final E value;

  bool _isSelected = false;

  Selectable._(this.value);

  bool get isSelected => _isSelected;

}
