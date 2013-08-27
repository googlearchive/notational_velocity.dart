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

  _testLuggage('trivial', (ol, cv) {
    _validate(ol, cv);
  });

  _testLuggage('simple filter', (ol, cv) {
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

  _testLuggage('simple sort', (ol, cv) {
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

  // TODO: sort & filter
  // TODO: change source collection
  // TODO: validate events
}

bool _isEven(int value) => value % 2 == 0;

bool _isOdd(int value) => !_isEven(value);

int _sortEvenFirst(int a, int b) => _nestedSort(a, b, [_sortEvenFirstSimple, (x, y) => x.compareTo(y)]);

int _sortOddFirst(int a, int b) => _nestedSort(a, b, [_sortOddFirstSimple, (x, y) => x.compareTo(y)]);

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

void _testLuggage(String name, Future testMethod(ObservableList<int> ol, CollectionView<int> cv)) {
  test(name, () {
    var ol = new ObservableList.from(_luggage);
    var cv = new CollectionView(ol);
    return testMethod(ol, cv);
  });
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
