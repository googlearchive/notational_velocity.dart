// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library cv_tests;

import 'dart:async';
import 'package:observe/observe.dart';
import 'package:nv/src/shared.dart';
import 'package:unittest/unittest.dart';
//import '../src/observe_test_utils.dart';
import 'test_read_only_observable_list.dart' as test_rool;

void main() {
  test_rool.sharedMain(_simpleFactory);
  _collectionViewTests();
}

void _collectionViewTests() {

  ObservableList<int> ol;
  CollectionView<int> cv;
  StreamSubscription sub;
  List<ChangeRecord> changes;

  void doChanges() {
    ol.deliverChanges();
    cv.deliverChanges();
  }

  setUp(() {
    ol = new ObservableList.from(_luggage);
    cv = new CollectionView(ol);
    changes = null;
    sub = cv.changes.listen((records) {
      changes = records;
    });
  });

  tearDown(() {
    sub.cancel();
  });

  test('trivial', () {
    _validate(ol, cv);
  });

  test('simple filter', () {
    _validate(ol, cv);

    cv.filter = _isEven;
    _validate(ol, cv);
    expect(cv, orderedEquals([2,4]));

    cv.filter = _isOdd;
    _validate(ol, cv);
    expect(cv, orderedEquals([1,3,5]));

    cv.filter = null;
    _validate(ol, cv);
    expect(cv, orderedEquals(_luggage));
  });

  test('simple sort', () {
    _validate(ol, cv);

    cv.sorter = _sortEvenFirst;
    _validate(ol, cv);
    expect(cv, orderedEquals([2,4,1,3,5]));

    cv.sorter = _sortOddFirst;
    _validate(ol, cv);
    expect(cv, orderedEquals([1,3,5,2,4]));

    cv.sorter = null;
    _validate(ol, cv);
    expect(cv, orderedEquals(_luggage));
  });

  test('sort and filter', () {
    _validate(ol, cv);

    cv.sorter = _sortDescending;
    _validate(ol, cv);
    expect(cv, orderedEquals([5,4,3,2,1]));

    cv.filter = _isOdd;
    _validate(ol, cv);
    expect(cv, orderedEquals([5,3,1]));

    cv.sorter = null;
    _validate(ol, cv);
    expect(cv, orderedEquals([1,3,5]));

    cv.filter = null;
    _validate(ol, cv);
    expect(cv, orderedEquals(_luggage));
  });

  test('sort and filter', () {
    _validate(ol, cv);

    cv.sorter = _sortDescending;
    _validate(ol, cv);
    expect(cv, orderedEquals([5,4,3,2,1]));

    ol.add(6);
    doChanges();

    _validate(ol, cv);
    expect(cv, orderedEquals([6,5,4,3,2,1]));

    cv.filter = _isOdd;
    _validate(ol, cv);
    expect(cv, orderedEquals([5,3,1]));

    ol.add(7);
    doChanges();
    _validate(ol, cv);
    expect(cv, orderedEquals([7,5,3,1]));

    cv.sorter = null;
    _validate(ol, cv);
    expect(cv, orderedEquals([1,3,5,7]));

    cv.filter = null;
    _validate(ol, cv);
    expect(cv, orderedEquals([1,2,3,4,5,6,7]));
  });

  // TODO: validate events
}

bool _isEven(int value) => value % 2 == 0;

bool _isOdd(int value) => !_isEven(value);

int _sortEvenFirst(int a, int b) => _nestedSort(a, b, const [_sortEvenFirstSimple, _sortAscending]);

int _sortOddFirst(int a, int b) => _nestedSort(a, b, const [_sortOddFirstSimple, _sortAscending]);

int _sortAscending(int a, int b) => a.compareTo(b);

int _sortDescending(int a, int b) => b.compareTo(a);

int _sortEvenFirstSimple(int a, int b) {
  int aEven = _isEven(a) ? 0 : 1;
  int bEven = _isEven(b) ? 0 : 1;
  return aEven.compareTo(bEven);
}

int _sortOddFirstSimple(int a, int b) => _sortEvenFirstSimple(b, a);

int _nestedSort(dynamic a, dynamic b, List<Sorter> sorters) {
  for(var sorter in sorters) {
    int value = sorter(a, b);
    if(value != 0) {
      return value;
    }
  }
  return 0;
}

void _validate(List<int> source, CollectionView<int> cv) {
  var testList = source.where(_getFilter(cv)).toList();
  if(cv.sorter != null) {
    testList.sort(cv.sorter);
  }
  expect(cv, orderedEquals(testList));
}

Predicate<int> _getFilter(CollectionView<int> cv) {
  return (cv.filter == null) ? (int foo) => true : cv.filter;
}

ObservableList<int> _simpleFactory(ObservableList<int> source) {
  return new CollectionView(source);
}

const _luggage = const [1,2,3,4,5];
