library test.nv.sync;

import 'dart:async';
import 'package:observe/observe.dart';
import 'package:unittest/unittest.dart';
import 'package:nv/src/storage.dart';
import 'package:nv/src/sync.dart';

import '../src/store_sync_test_util.dart';

void main(Storage store) {
  group('sync', () {

    test('create', () {

      return store.addAll(VALID_VALUES)
          .then((_) => MapSync.create(store))
          .then((ms) {
            expect(ms.map, equals(VALID_VALUES));
            expect(ms.updated, isTrue);
          });
    });

    _testMapSync('simple set', store, (MapSync mapSync) {

      var watcher = new EventWatcher<List<ChangeRecord>>();
      mapSync.changes.listen(watcher.handler);

      expect(mapSync.map, isEmpty);

      mapSync.map['a'] = 1;
      expect(mapSync.updated, isFalse);

      return watcher.listenOne()
          .then((List<ChangeRecord> records) {
            PropertyChangeRecord change = records.single;
            expect(change.field, const Symbol('updated'));
            expect(mapSync.updated, isTrue);

            return matchesMapValues(store, { 'a': 1 });
          });
    });

  });
}

void _testMapSync(String testName, Storage store, runner(MapSync store)) {
  test(testName, () {
    return MapSync.create(store).then(runner);
  });
}
