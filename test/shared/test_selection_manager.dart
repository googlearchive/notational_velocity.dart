library test.nv.shared.selection_manager;

import 'package:observe/observe.dart';
import 'package:nv/src/shared.dart';
import 'package:unittest/unittest.dart';

void main() {
  test("foo", () {

  });
}

SelectionManager<int> _getManager([Iterable<int> source]) {
  if(source == null) {
    source = [];
  }

  var ol = new ObservableList.from(source);
  return new SelectionManager<int>(source);
}
