library test.nv.shared.background_update;

import 'dart:async';
import 'package:observe/observe.dart';
import 'package:unittest/unittest.dart';

import '../src/observe_test_utils.dart';
import 'package:nv/src/shared.dart';

void main() {
  TestCase currentTest;
  int storedValue;
  int updateCount;
  BackgroundUpdate<int> bu;
  List<ChangeRecord> changes;
  StreamSubscription sub;

  Future updateFunc(int value) {
    assert(updateCount != null);
    assert(currentTest != null);
    assert(currentTestCase == currentTest);

    var requestUpdateCount = ++updateCount;

    return new Future(() {
      assert(requestUpdateCount == updateCount);
      assert(currentTest != null);
      assert(currentTestCase == currentTest);
      storedValue = value;
    });
  }

  tearDown((){
    sub.cancel();
    sub = null;
    currentTest = null;
    storedValue = null;
    updateCount = null;
    bu = null;
  });

  group('new value ctor', () {

    setUp(() {
      assert(currentTest == null);
      assert(storedValue == null);
      assert(updateCount == null);
      assert(bu == null);

      currentTest = currentTestCase;
      storedValue = null;
      updateCount = 0;

      bu = new BackgroundUpdate<int>.withNew(updateFunc, 42);
      sub = bu.changes.listen((List<ChangeRecord> val) {
        changes = val;
      });
    });

    test('simple update', () {
      expect(bu.deliverChanges(), isFalse);

      expect(bu.isUpdated, isFalse);
      expect(bu.value, 42);
      expect(updateCount, 1);

      expectChanges(changes, null);
      changes = null;

      return bu.updatedValue
          .then((int updatedValue) {
            expect(bu.isUpdated, isTrue);
            expect(bu.value, 42);
            expect(updatedValue, 42);
            expect(updateCount, 1);

            expect(bu.deliverChanges(), isTrue);
            expectChanges(changes, [_isUpdatedChanged]);
            changes = null;
          });
    });
  });

  group('default ctor', () {

    setUp(() {
      assert(currentTest == null);
      assert(storedValue == null);
      assert(updateCount == null);
      assert(bu == null);

      currentTest = currentTestCase;
      storedValue = null;
      updateCount = 0;

      bu = new BackgroundUpdate<int>(updateFunc, 0);
      sub = bu.changes.listen((List<ChangeRecord> val) {
        changes = val;
      });
    });

    test('simple', () {
      expect(bu.isUpdated, isTrue);
      expect(bu.value, 0);
      expect(updateCount, 0);
      expectChanges(changes, null);

      return bu.updatedValue
          .then((int updatedValue) {
            expect(bu.isUpdated, isTrue);
            expect(bu.value, 0);
            expect(updatedValue, 0);
            expect(updateCount, 0);
            expectChanges(changes, null);
          });
    });

    test('no-op update', () {
      bu.value = 0;

      expect(bu.isUpdated, isTrue);
      expect(bu.value, 0);
      expect(updateCount, 0);
      expectChanges(changes, null);

      return bu.updatedValue
          .then((int updatedValue) {
            expect(bu.isUpdated, isTrue);
            expect(bu.value, 0);
            expect(updatedValue, 0);
            expect(updateCount, 0);
            expectChanges(changes, null);
          });
    });

    test('simple update', () {
      bu.value = 1;

      expect(bu.deliverChanges(), isTrue);

      expect(bu.isUpdated, isFalse);
      expect(bu.value, 1);
      expect(updateCount, 1);

      expectChanges(changes, [_valueChanged, _isUpdatedChanged]);
      changes = null;

      return bu.updatedValue
          .then((int updatedValue) {
            expect(bu.isUpdated, isTrue);
            expect(bu.value, 1);
            expect(updatedValue, 1);
            expect(updateCount, 1);

            expect(bu.deliverChanges(), isTrue);
            expectChanges(changes, [_isUpdatedChanged]);
            changes = null;
          });
    });

    test('many changes, few updates', () {

      bu.value = 1;

      expect(bu.deliverChanges(), isTrue);

      expect(bu.isUpdated, isFalse);
      expect(bu.value, 1);
      expect(updateCount, 1);

      expectChanges(changes, [_valueChanged, _isUpdatedChanged]);
      changes = null;

      // update again, sync
      bu.value = 2;

      expect(bu.deliverChanges(), isTrue);

      expect(bu.isUpdated, isFalse);
      expect(bu.value, 2);
      expect(updateCount, 1);

      expectChanges(changes, [_valueChanged]);
      changes = null;

      // and again again, sync
      bu.value = 3;

      expect(bu.deliverChanges(), isTrue);

      expect(bu.isUpdated, isFalse);
      expect(bu.value, 3);
      expect(updateCount, 1);

      expectChanges(changes, [_valueChanged]);
      changes = null;

      return bu.updatedValue
          .then((int updatedValue) {
            expect(bu.isUpdated, isTrue);
            expect(bu.value, 3);
            expect(updatedValue, 3);
            expect(updateCount, 2);

            expect(bu.deliverChanges(), isTrue);
            expectChanges(changes, [_isUpdatedChanged]);
            changes = null;
          });
    });
  });
}

const _VALUE = const Symbol('value');
const _IS_UPDATED = const Symbol('isUpdated');

final _valueChanged = new PropertyChangeRecord(_VALUE);
final _isUpdatedChanged = new PropertyChangeRecord(_IS_UPDATED);

