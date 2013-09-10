library test.nv.shared.mapped_list_view;

import 'dart:async';
import 'package:observe/observe.dart';
import 'package:nv/src/shared.dart';
import 'package:unittest/unittest.dart';
import 'test_observable_list_view.dart' as test_rool;
import 'test_collection_view.dart' as test_cv;

void main() {
  group('identity', () {
    group('wrapping ReadOnlyObservableList', () {
      test_rool.sharedMain(_simpleFactory);
    });

    group('wrapping CollectionView', () {
      test_cv.sharedMain(_simpleFactory);
    });
  });

  group('core tests', () {
    ObservableList<int> ol;
    MappedListView<int, int> mlv;
    StreamSubscription sub;
    List<ChangeRecord> changes;

    setUp(() {
      ol = new ObservableList.from([1,2,3,4,5]);
      mlv = new MappedListView<int, int>(ol, _mapper);
      sub = mlv.changes.listen((List<ChangeRecord> val) {
        changes = val;
      });
    });

    tearDown(() {
      sub.cancel();
      sub = null;
      changes = null;
      ol = null;
      mlv = null;
    });

    test('two adds', () {
      ol.add(6);
      ol.removeAt(0);

      ol.deliverChanges();
      mlv.deliverChanges();
      expect(mlv, orderedEquals(ol.map(_mapper)));
      expect(changes, hasLength(2));
    });
  });

}

int _mapper(int source) {
  return source * 42;
}

ObservableList<int> _simpleFactory(ObservableList<int> source) {
  return new MappedListView<int, int>(source, _idMapper);
}

int _idMapper(int a) => a;
