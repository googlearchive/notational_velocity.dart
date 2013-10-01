library test.nv.shared.selection_manager;

import 'dart:async';
import 'package:observe/observe.dart';
import 'package:nv/src/shared.dart';
import 'package:unittest/unittest.dart';

import '../src/observe_test_utils.dart';

void main() {
  SelectionManager<int> manager;
  StreamSubscription sub;
  List<ChangeRecord> changes;

  setUp(() {
    var ol = new ObservableList.from([1,2,3,4,5]);
    manager = new SelectionManager(ol);
    sub = manager.changes.listen((List<ChangeRecord> val) {
      changes = val;
    });
    changes = null;
  });

  tearDown(() {
    sub.cancel();
    sub = null;
    manager = null;
  });

  bool deliverChanges() {
    changes = null;

    var sourceChanged = (manager.source as Observable).deliverChanges();
    var managerChanged = manager.deliverChanges();
    expect(managerChanged == true || sourceChanged == false, isTrue);
    return managerChanged;
  }

  test("no initial selection", () {
    _expectNoSelection(manager);
  });

  test('no selection, reflect changes in source', () {
    _expectNoSelection(manager);

    manager.source.add(6);
    manager.source.removeAt(0);

    expect(deliverChanges(), isTrue);

    _expectNoSelection(manager);
    expect(changes, hasLength(2));

    manager.source.clear();
    expect(deliverChanges(), isTrue);
    _expectNoSelection(manager);

    // length and list change
    expect(changes, hasLength(2));
  });

  test('selection changes via Selectable.isSelected', () {
    _expectNoSelection(manager);

    manager[0].isSelected = true;

    deliverChanges();

    expect(manager.selectedIndex, 0);
    expect(manager.selectedValue, 1);
    _expectSelection(manager);

    expectChanges(changes, [_selectedIndexChange, _selectedValueChange, _hasSelectionChange]);

    manager[4].isSelected = true;

    deliverChanges();

    expect(manager.selectedIndex, 4);
    expect(manager.selectedValue, 5);
    _expectSelection(manager);

    expectChanges(changes, [_selectedIndexChange, _selectedValueChange]);

    //
    // Setting selected item to nothing
    //
    expect(manager[4].isSelected, isTrue);
    manager[4].isSelected = false;

    deliverChanges();

    _expectNoSelection(manager);

    expectChanges(changes, [_selectedIndexChange, _selectedValueChange, _hasSelectionChange]);

    //
    // Back to a valid selection
    //
    manager[2].isSelected = true;

    deliverChanges();

    expect(manager.selectedIndex, 2);
    expect(manager.selectedValue, 3);
    _expectSelection(manager);

    expectChanges(changes, [_selectedIndexChange, _selectedValueChange, _hasSelectionChange]);

    //
    // Select the same item by value, no changes
    //
    manager[2].isSelected = true;

    deliverChanges();

    expect(manager.selectedIndex, 2);
    expect(manager.selectedValue, 3);
    _expectSelection(manager);

    expectChanges(changes, null);
  });

  test('selection changes via selectedIndex & selectedValue', () {
    _expectNoSelection(manager);

    manager.selectedIndex = 0;

    deliverChanges();

    expect(manager.selectedIndex, 0);
    expect(manager.selectedValue, 1);
    _expectSelection(manager);

    expectChanges(changes, [_selectedIndexChange, _selectedValueChange,
                            _hasSelectionChange]);

    manager.selectedValue = 5;

    deliverChanges();

    expect(manager.selectedIndex, 4);
    expect(manager.selectedValue, 5);
    _expectSelection(manager);

    expectChanges(changes, [_selectedIndexChange, _selectedValueChange]);


    //
    // Setting selected item to nothing
    //
    manager.selectedIndex = -1;

    deliverChanges();

    _expectNoSelection(manager);

    expectChanges(changes, [_selectedIndexChange, _selectedValueChange,
                            _hasSelectionChange]);

    //
    // Select a valid item, Select an item not in the list -> no selection
    //
    [null, -1, 0, 6].forEach((invalidSelectedItem) {

      manager.selectedValue = 3;

      deliverChanges();

      expect(manager.selectedIndex, 2);
      expect(manager.selectedValue, 3);
      _expectSelection(manager);

      expectChanges(changes, [_selectedIndexChange, _selectedValueChange,
                              _hasSelectionChange]);

      manager.selectedValue = invalidSelectedItem;

      deliverChanges();

      _expectNoSelection(manager);

      expectChanges(changes, [_selectedIndexChange, _selectedValueChange,
                              _hasSelectionChange]);
    });

    //
    // Back to a valid selection
    //
    manager.selectedValue = 3;

    deliverChanges();

    expect(manager.selectedIndex, 2);
    expect(manager.selectedValue, 3);
    _expectSelection(manager);

    expectChanges(changes, [_selectedIndexChange, _selectedValueChange,
                            _hasSelectionChange]);

    //
    // Select the same item by value, no changes
    //
    manager.selectedValue = 3;

    deliverChanges();

    expect(manager.selectedIndex, 2);
    expect(manager.selectedValue, 3);
    _expectSelection(manager);

    expectChanges(changes, null);

    //
    // Select the same item by index, no change
    //
    manager.selectedIndex = 2;

    deliverChanges();

    expect(manager.selectedIndex, 2);
    expect(manager.selectedValue, 3);
    _expectSelection(manager);

    expectChanges(changes, null);

  });

  test('collection changes after selection', () {

    _expectNoSelection(manager);

    //
    // Select the middle value and verify
    //
    manager.selectedValue = 3;

    deliverChanges();

    expect(manager.selectedIndex, 2);
    expect(manager.selectedValue, 3);
    _expectSelection(manager);

    expectChanges(changes, [_selectedIndexChange, _selectedValueChange,
                            _hasSelectionChange]);

    // remove item after selection: no change
    manager.source.remove(5);
    deliverChanges();

    expectChanges(changes, [lengthChange, change(4, removedCount: 1)]);
    expect(manager.selectedIndex, 2);
    expect(manager.selectedValue, 3);
    _expectSelection(manager);
    _expectNoSelectionChanges(changes);

    // add item after selection: no change
    manager.source.add(5);
    deliverChanges();

    expectChanges(changes, [lengthChange, change(4, addedCount: 1)]);
    expect(manager.selectedIndex, 2);
    expect(manager.selectedValue, 3);
    _expectSelection(manager);
    _expectNoSelectionChanges(changes);

    // replace item after selection: no change
    manager.source[4] = 7;
    deliverChanges();

    expect(manager[4].value, 7);

    expectChanges(changes, [change(4, addedCount: 1, removedCount: 1)]);
    expect(manager.selectedIndex, 2);
    expect(manager.selectedValue, 3);
    _expectSelection(manager);
    _expectNoSelectionChanges(changes);

  });

  test('collection changes before selection', () {

    _expectNoSelection(manager);

    //
    // Select the middle value and verify
    //
    manager.selectedValue = 3;

    deliverChanges();

    expect(manager.selectedIndex, 2);
    expect(manager.selectedValue, 3);
    _expectSelection(manager);

    expectChanges(changes, [_selectedIndexChange, _selectedValueChange,
                            _hasSelectionChange]);

    // replace item before selection, no change
    manager.source[0] = 8;
    deliverChanges();

    expect(manager[0].value, 8);

    expectChanges(changes, [change(0, addedCount: 1, removedCount: 1)]);
    expect(manager.selectedIndex, 2);
    expect(manager.selectedValue, 3);
    _expectSelection(manager);
    _expectNoSelectionChanges(changes);

    //
    // NON-TRIVIAL changes ahead
    //

    // remove item before selection: no change
    expect(manager[0].value, 8);
    manager.source.remove(8);
    deliverChanges();

    expect(manager[0].value, 2);
    expect(manager[1].value, 3);
    expect(manager[1].isSelected, isTrue);

    expectChanges(changes, [lengthChange, change(0, removedCount: 1),
                            _selectedIndexChange]);
    expect(manager.selectedValue, 3);
    expect(manager.selectedIndex, 1);
    _expectSelection(manager);

    // add item before selection
    manager.source.insert(0, 9);
    deliverChanges();

    expect(manager[0].value, 9);
    expect(manager[2].value, 3);
    expect(manager[2].isSelected, isTrue);

    expectChanges(changes, [lengthChange, change(0, addedCount: 1),
                            _selectedIndexChange]);
    expect(manager.selectedIndex, 2);
    expect(manager.selectedValue, 3);
    _expectSelection(manager);
  });

  test('no selection with collection changes', () {

    _expectNoSelection(manager);

    manager.source.add(6);
    deliverChanges();

    expectChanges(changes, [lengthChange, change(5, addedCount: 1)]);
    _expectNoSelectionChanges(changes);
    _expectNoSelection(manager);

    manager.source.remove(6);
    deliverChanges();

    expectChanges(changes, [lengthChange, change(5, removedCount: 1)]);
    _expectNoSelectionChanges(changes);
    _expectNoSelection(manager);

    manager.source.insert(0, 0);
    deliverChanges();

    expectChanges(changes, [lengthChange, change(0, addedCount: 1)]);
    _expectNoSelectionChanges(changes);
    _expectNoSelection(manager);

    manager.source[0] = 10;
    deliverChanges();

    // silly double check
    expect(manager[0].value, 10);

    expectChanges(changes, [change(0, addedCount: 1, removedCount: 1)]);
    _expectNoSelectionChanges(changes);
    _expectNoSelection(manager);

    manager.source.removeAt(0);
    deliverChanges();

    expectChanges(changes, [lengthChange, change(0, removedCount: 1)]);
    _expectNoSelectionChanges(changes);
    _expectNoSelection(manager);

  });

  test('remove the selected item', () {
    _expectNoSelection(manager);

    var targetItem = manager[2];

    List<ChangeRecord> itemChanges;
    targetItem.changes.listen((val) {
      itemChanges = val;
    });

    //
    // Select the middle value and verify
    //
    manager.selectedValue = 3;

    deliverChanges();
    targetItem.deliverChanges();

    expectChanges(itemChanges, [_isSelectedChange]);

    expect(manager.selectedIndex, 2);
    expect(manager.selectedValue, 3);
    _expectSelection(manager);

    expectChanges(changes, [_selectedIndexChange, _selectedValueChange,
                            _hasSelectionChange]);

    //
    // Remove the selected item
    //
    expect(targetItem.isSelected, isTrue);
    manager.source.removeAt(2);

    // Added 'early' tests here to validate that changes are reflected
    // immediately
    expect(manager[2].value, 4);
    expect(manager[2].isSelected, isFalse);
    _expectNoSelection(manager);

    deliverChanges();
    targetItem.deliverChanges();

    expectChanges(itemChanges, [_isSelectedChange]);

    expect(manager[2].value, 4);
    expect(manager[2].isSelected, isFalse);

    expectChanges(changes, [lengthChange, change(2, removedCount: 1),
                            _selectedIndexChange, _selectedValueChange,
                            _hasSelectionChange]);
    _expectNoSelection(manager);

    // The now removed item should act like orphan-like
    expect(targetItem.isSelected, isNull);
    expect(() {
      targetItem.isSelected = true;
    }, throws);
  });

  test('add item and select, without deliver changes', () {
    _expectNoSelection(manager);

    manager.source.add(10);
    manager.selectedValue = 10;

    deliverChanges();

    expectChanges(changes, [_selectedIndexChange, _selectedValueChange,
                            _hasSelectionChange, lengthChange,
                            change(5, addedCount: 1)]);
    expect(manager.selectedIndex, 5);
    expect(manager.selectedValue, 10);
    _expectSelection(manager);
  });

  test('select A, remove A, add B, select B, without deliver changes', () {

    _expectNoSelection(manager);

    manager.selectedIndex = 2;
    expect(manager.selectedValue, 3);

    var removedVal = manager.source.removeAt(2);
    expect(removedVal, 3);
    expect(manager.source, hasLength(4));

    manager.source.add(10);
    manager.selectedValue = 10;

    deliverChanges();

    expectChanges(changes, [_hasSelectionChange, _selectedIndexChange,
                            _selectedValueChange,
                            change(2, removedCount: 1),
                            change(4, addedCount: 1)]);
    expect(manager.selectedIndex, 4);
    expect(manager.selectedValue, 10);
  });

  test('select, remove item, select new item with old index - regression #27', () {
    _expectNoSelection(manager);

    // select the item at index 0
    manager.selectedValue = 1;

    // remove item at index 0
    manager.source.remove(1);

    // select the item *now* at index 0, before change events propogate
    manager.selectedValue = 2;

    expect(manager.selectedIndex, 0);
    expect(manager.selectedValue, 2);
  });

  test('select an item, add 5 more before selection, regression #36', () {
    _expectNoSelection(manager);

    // select the item at index 0
    manager.selectedValue = 5;

    expect(manager.selectedValue, 5);
    expect(manager.selectedIndex, 4);

    manager.source.insertAll(0, [6,7,8,9,10]);

    expect(manager.selectedIndex, 9, reason: 'selectedIndex should change');
    expect(manager.selectedValue, 5, reason: 'selectedValue should not change');
    _expectSelection(manager);
  });
}

void _expectNoSelection(SelectionManager manager) {
  _expectAlignment(manager);

  expect(manager.selectedValue, isNull);
  expect(manager.selectedIndex, equals(-1));
  expect(manager.hasSelection, isFalse);
  expect(manager.any((s) => s.isSelected), isFalse);
}

void _expectNoSelectionChanges(List<ChangeRecord> changes) {
  var safeChanges = (changes == null) ? [] : changes;

  var propChangeSymbols = safeChanges
      .where((ChangeRecord cr) => cr is PropertyChangeRecord)
      .map((PropertyChangeRecord pcr) => pcr.field)
      .toList();

  const selectChangeFields = const [_HAS_SELECTION,
                                    _SELECTED_INDEX,
                                    _SELECTED_VALUE];

  selectChangeFields.forEach((field) {
    expect(propChangeSymbols, isNot(contains(field)));
  });
}

void _expectSelection(SelectionManager manager) {
  _expectAlignment(manager);

  expect(manager.hasSelection, isTrue);
  var index = manager.selectedIndex;
  expect(index, isNotNull);
  expect(index >= 0, isTrue);
  expect(manager.selectedValue, equals(manager[index].value));
  expect(manager[index].isSelected, isTrue);

  var singleSelected = manager.singleWhere((s) => s.isSelected);
  expect(singleSelected.value, equals(manager.selectedValue));
}

void _expectAlignment(SelectionManager manager) {
  expect(manager.length, equals(manager.source.length));
  for(var i = 0; i < manager.length; i++) {
    expect(manager[i].value, equals(manager.source[i]));
  }
}

const _SELECTED_INDEX = const Symbol('selectedIndex');
const _HAS_SELECTION = const Symbol('hasSelection');
const _SELECTED_VALUE = const Symbol('selectedValue');
const _IS_SELECTED = const Symbol('isSelected');

final _selectedIndexChange = new PropertyChangeRecord(_SELECTED_INDEX);
final _hasSelectionChange = new PropertyChangeRecord(_HAS_SELECTION);
final _selectedValueChange = new PropertyChangeRecord(_SELECTED_VALUE);
final _isSelectedChange = new PropertyChangeRecord(_IS_SELECTED);
