library test.nv.shared;

import 'package:unittest/unittest.dart';

import 'test_collection_view.dart' as cv;
import 'test_mapped_list_view.dart' as mlv;
import 'test_observable_list_view.dart' as rol;
import 'test_selection_manager.dart' as sm;
import 'test_split.dart' as split;

void main() {
  group('shared', () {
    group('CollectionView', cv.main);
    group('MappedListView', mlv.main);
    group('ObservableListView', rol.main);
    group('SelectionManager', sm.main);
    group('Split', split.main);
  });
}
