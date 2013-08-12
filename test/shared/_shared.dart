library test.nv.shared;

import 'package:unittest/unittest.dart';
import 'read_only_observable_list_tests.dart' as rol;
import 'split_tests.dart' as split;

void main() {
  group('ReadOnlyObservableList', rol.main);
  group('Split', split.main);
}
