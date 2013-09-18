library test.nv.shared.observable_set;

import 'package:observe/observe.dart';
import 'package:nv/src/shared.dart';
import 'package:unittest/unittest.dart';

import '../src/observe_test_utils.dart';

void main() {
  test('empty', () {
    var set = new ObservableSet();

    expect(set, isEmpty);

    set = new ObservableSet.from([]);

    expect(set, isEmpty);
  });

  test('values', () {
    var set = new ObservableSet.from([1,2,3,3,2,1]);
    List<ChangeRecord> changes;

    set.changes.listen((List<ChangeRecord> val) {
      changes = val;
    });

    expect(set, orderedEquals([1,2,3]));

    set.add(1);
    expect(set.deliverChanges(), isFalse);
    expectChanges(changes, null);

    expect(set, orderedEquals([1,2,3]));

    set.addAll([3,4,5,6,1,-1]);
    expect(set.deliverChanges(), isTrue);

    expectChanges(changes, [lengthChange,
                            change(0, addedCount: 1),
                            change(4, addedCount: 3)]);

    expect(set, orderedEquals([-1,1,2,3,4,5,6]));

    changes = null;

    expect(set.remove(5), isTrue);
    expect(set.deliverChanges(), isTrue);

    expectChanges(changes, [lengthChange,
                            change(5, removedCount: 1)]);

    changes = null;

    expect(set.remove(5), isFalse);
    expect(set.deliverChanges(), isFalse);
    expectChanges(changes, null);


    const target = const[-1,1,2,3,4,6];
    expect(set, orderedEquals(target));

    for(var i = 0; i < set.length; i++) {
      expect(set[i], target[i]);
    }
  });
}
