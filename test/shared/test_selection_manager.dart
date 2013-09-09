library test.nv.shared.selection_manager;

import 'package:observe/observe.dart';
import 'package:nv/src/shared.dart';
import 'package:unittest/unittest.dart';

void main() {
  test("no initial selection", () {
    SelectionManager<int> manager = _getManager();

    _expectNoSelection(manager);
  });

  // initially, no item is selected

  // mark item selected by calling item method

  // mark another item selected by calling list method

  // select same item again -> no events

  // remove item from source list -> watch for events
}

void _expectNoSelection(SelectionManager manager) {
  _expectAlignment(manager);

  expect(manager.selectedItem, isNull);
  expect(manager.selectedIndex, isNull);
  expect(manager.hasSelection, isFalse);
  expect(manager.any((s) => s.isSelected), isFalse);
}

void _expectSelection(SelectionManager manager) {
  _expectAlignment(manager);

  expect(manager.hasSelection, isTrue);
  var index = manager.selectedIndex;
  expect(index, isNotNull);
  expect(index >= 0, isTrue);
  expect(manager.selectedItem, equals(manager[index].value));
  expect(manager[index].isSelected, isTrue);

  var singleSelected = manager.singleWhere((s) => s.isSelected);
  expect(singleSelected.value, equals(manager.selectedItem));
}

void _expectAlignment(SelectionManager manager) {
  expect(manager.length, equals(manager.source.length));
  for(var i = 0; i < manager.length; i++) {
    expect(manager[i].value, equals(manager.source[i]));
  }
}

SelectionManager<int> _getManager([Iterable<int> source = const [1,2,3,4,5]]) {
  if(source == null) {
    source = [];
  }

  var ol = new ObservableList.from(source);
  return new SelectionManager<int>(ol);
}
