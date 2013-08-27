library test.nv.shared;

import 'package:unittest/unittest.dart';

import 'test_collection_view.dart' as cv;
import 'test_read_only_observable_list.dart' as rol;
import 'test_split.dart' as split;

void main() {
  group('CollectionView', cv.main);
  group('ReadOnlyObservableList', rol.main);
  group('Split', split.main);
}
