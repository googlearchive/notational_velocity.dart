// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library rol_tests;

import 'dart:async';
import 'package:observe/observe.dart';
import 'package:nv/src/shared.dart';
import 'package:unittest/unittest.dart';
import '../src/observe_test_utils.dart';

// TODO: test mutation operations throw appropriate errors

typedef ObservableList<E> ROOLFactory<E>(ObservableList<E> source);

void main() {
  sharedMain(_simpleFactory);
}

ObservableListView<int> _simpleFactory(ObservableList<int> source) {
  return new ObservableListView(source);
}

void sharedMain(ROOLFactory factory) {
  // TODO(jmesserly): need all standard List API tests.

  StreamSubscription sub;
  ObservableList list;
  ObservableList rol;
  List<ChangeRecord> changes;

  void doChanges() {
    list.deliverChanges();
    rol.deliverChanges();
  }

  void sharedTearDown() { sub.cancel(); }

  group('observe length', () {

    setUp(() {
      list = toObservable([1, 2, 3]);
      rol = factory(list);
      changes = null;
      sub = rol.changes.listen((records) {
        changes = records.where((r) => r.changes(_LENGTH)).toList();
      });
    });

    tearDown(sharedTearDown);

    test('add changes length', () {
      list.add(4);
      doChanges();
      expect(rol, [1, 2, 3, 4]);
      expectChanges(changes, [_lengthChange]);
    });

    test('removeObject', () {
      list.remove(2);
      doChanges();
      expect(rol, orderedEquals([1, 3]));
      expectChanges(changes, [_lengthChange]);
    });

    test('removeRange changes length', () {
      list.add(4);
      list.removeRange(1, 3);
      doChanges();
      expect(rol, [1, 4]);
      expectChanges(changes, [_lengthChange]);
    });

    test('length= changes length', () {
      list.length = 5;
      doChanges();
      expect(rol, [1, 2, 3, null, null]);
      expectChanges(changes, [_lengthChange]);
    });

    test('[]= does not change length', () {
      list[2] = 9000;
      doChanges();
      expect(rol, [1, 2, 9000]);
      expectChanges(changes, []);
    });

    test('clear changes length', () {
      list.clear();
      doChanges();
      expect(rol, []);
      expectChanges(changes, [_lengthChange]);
    });
  });

  group('observe index', () {

    setUp(() {
      list = toObservable([1, 2, 3]);
      rol = factory(list);
      changes = null;
      sub = rol.changes.listen((records) {
        changes = records.where((r) => r.changes(1)).toList();
      });
    });

    tearDown(sharedTearDown);

    test('add does not change existing items', () {
      list.add(4);
      doChanges();
      expect(rol, [1, 2, 3, 4]);
      expectChanges(changes, []);
    });

    test('[]= changes item', () {
      list[1] = 777;
      doChanges();
      expect(rol, [1, 777, 3]);
      expectChanges(changes, [_change(1, addedCount: 1, removedCount: 1)]);
    });

    test('[]= on a different item does not fire change', () {
      list[2] = 9000;
      doChanges();
      expect(rol, [1, 2, 9000]);
      expectChanges(changes, []);
    });

    test('set multiple times results in one change', () {
      list[1] = 777;
      list[1] = 42;
      doChanges();
      expect(rol, [1, 42, 3]);
      expectChanges(changes, [
        _change(1, addedCount: 1, removedCount: 1),
      ]);
    });

    test('set length without truncating item means no change', () {
      list.length = 2;
      doChanges();
      expect(rol, [1, 2]);
      expectChanges(changes, []);
    });

    test('truncate removes item', () {
      list.length = 1;
      doChanges();
      expect(rol, [1]);
      expectChanges(changes, [_change(1, removedCount: 2)]);
    });

    test('truncate and add new item', () {
      list.length = 1;
      list.add(42);
      doChanges();
      expect(rol, [1, 42]);
      expectChanges(changes, [
        _change(1, removedCount: 2, addedCount: 1)
      ]);
    });

    test('truncate and add same item', () {
      list.length = 1;
      list.add(2);
      doChanges();
      expect(rol, [1, 2]);
      expectChanges(changes, [
        _change(1, removedCount: 2, addedCount: 1)
      ]);
    });
  });

  test('toString', () {
    var list = toObservable([1, 2, 3]);
    var rol = factory(list);
    expect(rol.toString(), '[1, 2, 3]');
  });

  group('change records', () {

    setUp(() {
      list = toObservable([1, 2, 3, 1, 3, 4]);
      rol = factory(list);
      changes = null;
      sub = rol.changes.listen((r) { changes = r; });
    });

    tearDown(sharedTearDown);

    test('read operations', () {
      expect(rol.length, 6);
      expect(rol[0], 1);
      expect(rol.indexOf(4), 5);
      expect(rol.indexOf(1), 0);
      expect(rol.indexOf(1, 1), 3);
      expect(rol.lastIndexOf(1), 3);
      expect(rol.last, 4);
      var copy = new List<int>();
      rol.forEach((i) { copy.add(i); });
      expect(copy, orderedEquals([1, 2, 3, 1, 3, 4]));
      doChanges();

      // no change from read-only operators
      expectChanges(changes, null);
    });

    test('remove, removeAt', () {
      list.remove(1);
      doChanges();
      expect(rol, orderedEquals([2, 3, 1, 3, 4]));

      expectChanges(changes, [
        _lengthChange,
        _change(0, removedCount: 1, addedCount: 0)
      ]);

      list.remove(1);
      doChanges();
      expect(rol, orderedEquals([2, 3, 3, 4]));

      expectChanges(changes, [
        _lengthChange,
        _change(2, removedCount: 1, addedCount: 0)
      ]);

      list.removeAt(1);
      doChanges();
      expect(rol, orderedEquals([2, 3, 4]));

      expectChanges(changes, [
        _lengthChange,
        _change(1, removedCount: 1, addedCount: 0)
      ]);
    });

    test('add', () {
      list.add(5);
      list.add(6);
      doChanges();
      expect(rol, orderedEquals([1, 2, 3, 1, 3, 4, 5, 6]));

      expectChanges(changes, [
        _lengthChange,
        _change(6, addedCount: 2)
      ]);
    });

    test('[]=', () {
      list[1] = list.last;
      doChanges();
      expect(rol, orderedEquals([1, 4, 3, 1, 3, 4]));

      expectChanges(changes, [ _change(1, addedCount: 1, removedCount: 1) ]);
    });

    test('removeLast', () {
      expect(list.removeLast(), 4);
      doChanges();
      expect(rol, orderedEquals([1, 2, 3, 1, 3]));

      expectChanges(changes, [
        _lengthChange,
        _change(5, removedCount: 1)
      ]);
    });

    test('removeRange', () {
      list.removeRange(1, 4);
      doChanges();
      expect(rol, orderedEquals([1, 3, 4]));

      expectChanges(changes, [
        _lengthChange,
        _change(1, removedCount: 3),
      ]);
    });

    test('sort', () {
      list.sort((x, y) => x - y);
      doChanges();
      expect(rol, orderedEquals([1, 1, 2, 3, 3, 4]));

      expectChanges(changes, [
        _change(1, addedCount: 5, removedCount: 5),
      ]);
    });

    test('clear', () {
      list.clear();
      doChanges();
      expect(rol, []);

      expectChanges(changes, [
        _lengthChange,
        _change(0, removedCount: 6)
      ]);
    });
  });
}

const _LENGTH = const Symbol('length');

final _lengthChange = new PropertyChangeRecord(_LENGTH);

ListChangeRecord _change(index, {removedCount: 0, addedCount: 0}) =>
    new ListChangeRecord(index, removedCount: removedCount,
        addedCount: addedCount);
