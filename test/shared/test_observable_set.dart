library test.nv.shared.selection_manager;

import 'package:nv/src/shared.dart';
import 'package:unittest/unittest.dart';

void main() {
  test('empty', () {
    var set = new ObservableSet();

    expect(set, isEmpty);

    set = new ObservableSet.from([]);

    expect(set, isEmpty);
  });

  test('values', () {
    var set = new ObservableSet.from([1,2,3,3,2,1]);

    expect(set, orderedEquals([1,2,3]));

    set.add(1);

    expect(set, orderedEquals([1,2,3]));

    set.addAll([3,4,5,6,1,-1]);

    expect(set, orderedEquals([-1,1,2,3,4,5,6]));

    set.remove(5);

    const target = const[-1,1,2,3,4,6];
    expect(set, orderedEquals(target));

    for(var i = 0; i < set.length; i++) {
      expect(set[i], target[i]);
    }
  });
}
