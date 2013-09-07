library test.nv.shared.mapped_list_view;

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
}

ObservableList<int> _simpleFactory(ObservableList<int> source) {
  return new MappedListView<int, int>(source, _idMapper);
}

int _idMapper(int a) => a;
