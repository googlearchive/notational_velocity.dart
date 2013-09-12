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

    var sourceChanged = manager.source.deliverChanges();
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

  test('simple selection changes', () {

    // TODO: need to test changing selection by calling property on the item

    _expectNoSelection(manager);

    manager.selectedIndex = 0;

    deliverChanges();

    expect(manager.selectedIndex, 0);
    expect(manager.selectedValue, 1);
    _expectSelection(manager);

    _expectPropChanges(changes, ['hasSelection', 'selectedIndex',
                                 'selectedItem']);

    manager.selectedValue = 5;

    deliverChanges();

    expect(manager.selectedIndex, 4);
    expect(manager.selectedValue, 5);
    _expectSelection(manager);

    _expectPropChanges(changes, ['selectedIndex', 'selectedItem']);

    //
    // Setting selected item to nothing
    //
    manager.selectedIndex = -1;

    deliverChanges();

    _expectNoSelection(manager);

    _expectPropChanges(changes, ['hasSelection', 'selectedIndex',
                                 'selectedItem']);

    //
    // Select a valid item, Select an item not in the list -> no selection
    //
    [null, -1, 0, 6].forEach((invalidSelectedItem) {

      manager.selectedValue = 3;

      deliverChanges();

      expect(manager.selectedIndex, 2);
      expect(manager.selectedValue, 3);
      _expectSelection(manager);

      _expectPropChanges(changes, ['hasSelection', 'selectedIndex',
                                   'selectedItem']);

      manager.selectedValue = invalidSelectedItem;

      deliverChanges();

      _expectNoSelection(manager);

      _expectPropChanges(changes, ['hasSelection', 'selectedIndex',
                                   'selectedItem']);
    });

    //
    // Back to a valid selection
    //
    manager.selectedValue = 3;

    deliverChanges();

    expect(manager.selectedIndex, 2);
    expect(manager.selectedValue, 3);
    _expectSelection(manager);

    _expectPropChanges(changes, ['hasSelection', 'selectedIndex',
                                 'selectedItem']);

    //
    // Select the same item by value, no changes
    //
    manager.selectedValue = 3;

    deliverChanges();

    expect(manager.selectedIndex, 2);
    expect(manager.selectedValue, 3);
    _expectSelection(manager);

    _expectPropChanges(changes, []);

    //
    // Select the same item by index, no change
    //
    manager.selectedIndex = 2;

    deliverChanges();

    expect(manager.selectedIndex, 2);
    expect(manager.selectedValue, 3);
    _expectSelection(manager);

    _expectPropChanges(changes, []);

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

    _expectPropChanges(changes, ['hasSelection', 'selectedIndex',
                                 'selectedItem']);

    // remove item after selection: no change
    manager.source.remove(5);
    deliverChanges();

    expectChanges(changes, [_lengthChange, _change(4, removedCount: 1)]);
    expect(manager.selectedIndex, 2);
    expect(manager.selectedValue, 3);
    _expectSelection(manager);
    _expectNoSelectionChanges(changes);

    // add item after selection: no change
    manager.source.add(5);
    deliverChanges();

    expectChanges(changes, [_lengthChange, _change(4, addedCount: 1)]);
    expect(manager.selectedIndex, 2);
    expect(manager.selectedValue, 3);
    _expectSelection(manager);
    _expectNoSelectionChanges(changes);

    // replace item after selection: no change
    manager.source[4] = 7;
    deliverChanges();

    expect(manager[4].value, 7);

    expectChanges(changes, [_change(4, addedCount: 1, removedCount: 1)]);
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

    _expectPropChanges(changes, ['hasSelection', 'selectedIndex',
                                 'selectedItem']);

    // replace item before selection, no change
    manager.source[0] = 8;
    deliverChanges();

    expect(manager[0].value, 8);

    expectChanges(changes, [_change(0, addedCount: 1, removedCount: 1)]);
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

    expectChanges(changes, [_lengthChange, _change(0, removedCount: 1),
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

    expectChanges(changes, [_lengthChange, _change(0, addedCount: 1),
                            _selectedIndexChange]);
    expect(manager.selectedIndex, 2);
    expect(manager.selectedValue, 3);
    _expectSelection(manager);
  });

  test('no selection with collection changes', () {

    _expectNoSelection(manager);

    manager.source.add(6);
    deliverChanges();

    expectChanges(changes, [_lengthChange, _change(5, addedCount: 1)]);
    _expectNoSelectionChanges(changes);
    _expectNoSelection(manager);

    manager.source.remove(6);
    deliverChanges();

    expectChanges(changes, [_lengthChange, _change(5, removedCount: 1)]);
    _expectNoSelectionChanges(changes);
    _expectNoSelection(manager);

    manager.source.insert(0, 0);
    deliverChanges();

    expectChanges(changes, [_lengthChange, _change(0, addedCount: 1)]);
    _expectNoSelectionChanges(changes);
    _expectNoSelection(manager);

    manager.source[0] = 10;
    deliverChanges();

    // silly double check
    expect(manager[0].value, 10);

    expectChanges(changes, [_change(0, addedCount: 1, removedCount: 1)]);
    _expectNoSelectionChanges(changes);
    _expectNoSelection(manager);

    manager.source.removeAt(0);
    deliverChanges();

    expectChanges(changes, [_lengthChange, _change(0, removedCount: 1)]);
    _expectNoSelectionChanges(changes);
    _expectNoSelection(manager);

  });
}

void _expectPropChanges(List<ChangeRecord> changes, List<Symbol> propNames) {
  var safeChanges = (changes == null) ? [] : changes;

  var propChangeSymbols = safeChanges
      .where((ChangeRecord cr) => cr is PropertyChangeRecord)
      .map((PropertyChangeRecord pcr) => pcr.field)
      .toList();

  var propSymbols = propNames.map((n) => new Symbol(n)).toList();

  expect(propChangeSymbols, unorderedEquals(propSymbols));
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

  const selectChangeFields = const [const Symbol('hasSelection'),
                                    _SELECTED_INDEX,
                                    const Symbol('selectedItem')];

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

const _LENGTH = const Symbol('length');
const _SELECTED_INDEX = const Symbol('selectedIndex');

final _lengthChange = new PropertyChangeRecord(_LENGTH);
final _selectedIndexChange = new PropertyChangeRecord(_SELECTED_INDEX);

ListChangeRecord _change(index, {removedCount: 0, addedCount: 0}) =>
    new ListChangeRecord(index, removedCount: removedCount,
        addedCount: addedCount);
