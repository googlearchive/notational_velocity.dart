library test.nv.shared.selection_manager;

import 'dart:async';
import 'package:observe/observe.dart';
import 'package:nv/src/shared.dart';
import 'package:unittest/unittest.dart';

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
  });

  tearDown(() {
    sub.cancel();
    sub = null;
    changes = null;
    manager = null;
  });

  bool deliverChanges() {
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

  test('selection dance', () {

    _expectNoSelection(manager);

    manager.selectedIndex = 0;

    deliverChanges();

    expect(manager.selectedIndex, 0);
    expect(manager.selectedItem, 1);
    expect(manager.hasSelection, isTrue);

    _expectPropChanges(changes, ['hasSelection', 'selectedIndex',
                                 'selectedItem']);

    manager.selectedItem = 5;

    deliverChanges();

    expect(manager.selectedIndex, 4);
    expect(manager.selectedItem, 5);
    expect(manager.hasSelection, isTrue);

    _expectPropChanges(changes, ['selectedIndex', 'selectedItem']);


    // initially, no item is selected

    // mark item selected by calling item method

    // mark another item selected by calling list method

    // select same item again -> no events

    // remove item from source list -> watch for events
  });
}

void _expectPropChanges(List<ChangeRecord> changes, List<Symbol> propNames) {
  var propChangeSymbols = changes
      .where((ChangeRecord cr) => cr is PropertyChangeRecord)
      .map((PropertyChangeRecord pcr) => pcr.field)
      .toList();

  var propSymbols = propNames.map((n) => new Symbol(n)).toList();

  expect(propChangeSymbols, unorderedEquals(propSymbols));
}

void _expectNoSelection(SelectionManager manager) {
  _expectAlignment(manager);

  expect(manager.selectedItem, isNull);
  expect(manager.selectedIndex, equals(-1));
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
