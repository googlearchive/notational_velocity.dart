library test.nv.shared.collection_view;

import 'dart:async';
import 'package:observe/observe.dart';
import 'package:nv/src/shared.dart';
import 'package:unittest/unittest.dart';
import 'test_observable_list_view.dart' as test_rool;

void main() {
  test_rool.sharedMain(_simpleFactory);
  sharedMain((cv) => cv);
}

typedef ObservableList<E> CVtoOLFoctary<E>(CollectionView<E> source);

void sharedMain(CVtoOLFoctary<int> factory) {

  ObservableList<int> ol;
  CollectionView<int> collView;
  ObservableList<int> finalView;

  StreamSubscription sub;
  List<ChangeRecord> changes;

  void doChanges() {
    ol.deliverChanges();
    collView.deliverChanges();
    finalView.deliverChanges();
  }

  void validate() {
    _validateRaw(ol, collView.sorter, collView.filter, finalView);
  }

  setUp(() {
    ol = new ObservableList.from(_luggage);
    collView = new CollectionView(ol);
    finalView = factory(collView);
    changes = null;
    sub = finalView.changes.listen((records) {
      changes = records;
    });
  });

  tearDown(() {
    sub.cancel();
  });

  test('trivial', () {
    validate();
  });

  test('simple filter', () {
    validate();

    collView.filter = _isEven;
    validate();
    expect(finalView, orderedEquals([2,4]));

    collView.filter = _isOdd;
    validate();
    expect(finalView, orderedEquals([1,3,5]));

    collView.filter = null;
    validate();
    expect(finalView, orderedEquals(_luggage));
  });

  test('simple sort', () {
    validate();

    collView.sorter = _sortEvenFirst;
    validate();
    expect(finalView, orderedEquals([2,4,1,3,5]));

    collView.sorter = _sortOddFirst;
    validate();
    expect(finalView, orderedEquals([1,3,5,2,4]));

    collView.sorter = null;
    validate();
    expect(finalView, orderedEquals(_luggage));
  });

  test('sort and filter', () {
    validate();

    collView.sorter = _sortDescending;
    validate();
    expect(finalView, orderedEquals([5,4,3,2,1]));

    collView.filter = _isOdd;
    validate();
    expect(finalView, orderedEquals([5,3,1]));

    collView.sorter = null;
    validate();
    expect(finalView, orderedEquals([1,3,5]));

    collView.filter = null;
    validate();
    expect(finalView, orderedEquals(_luggage));
  });

  test('sort and filter', () {
    validate();

    collView.sorter = _sortDescending;
    validate();
    expect(finalView, orderedEquals([5,4,3,2,1]));

    ol.add(6);
    doChanges();

    validate();
    expect(finalView, orderedEquals([6,5,4,3,2,1]));

    collView.filter = _isOdd;
    validate();
    expect(finalView, orderedEquals([5,3,1]));

    ol.add(7);
    doChanges();
    validate();
    expect(finalView, orderedEquals([7,5,3,1]));

    collView.sorter = null;
    validate();
    expect(finalView, orderedEquals([1,3,5,7]));

    collView.filter = null;
    validate();
    expect(finalView, orderedEquals([1,2,3,4,5,6,7]));
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

void _validateRaw(List<int> source, Sorter<int> sorter, Predicate<int> filter, List<int> target) {
  var testList = source.where(_getFilter(filter)).toList();
  if(sorter != null) {
    testList.sort(sorter);
  }
  expect(target, orderedEquals(testList));
}

Predicate<int> _getFilter(Predicate<int> filter) {
  return (filter == null) ? (int foo) => true : filter;
}

ObservableList<int> _simpleFactory(ObservableList<int> source) {
  return new CollectionView(source);
}

const _luggage = const [1,2,3,4,5];
