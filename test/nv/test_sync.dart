library test.nv.sync;

import 'dart:async';
import 'package:observe/observe.dart';
import 'package:unittest/unittest.dart';
import 'package:nv/src/storage.dart';
import 'package:nv/src/sync.dart';

import '../src/store_sync_test_util.dart';

void main(Storage store) {
  group('MapSync', () {

    test('create', () {

      return store.addAll(VALID_VALUES)
          .then((_) => MapSync.createAndLoad(store))
          .then((ms) {
            expect(ms.map, equals(VALID_VALUES));
            expect(ms.isUpdated, isTrue);
          });
    });

    _testMapSync('simple set', store, (MapSync mapSync) {

      expect(mapSync.map, isEmpty);

      return _expectSyncMapWithDeltaMap(store, mapSync,
          { 'a' : 1 },
          { 'a': 1 })
          .then((_) {
            return _expectSyncMapWithDeltaMap(store, mapSync,
                { 'b' : 2 },
                { 'a': 1, 'b': 2 });
          })
          .then((_) {
            return _expectSyncMapWithDeltaMap(store, mapSync,
                { 'b' : 3 },
                { 'a': 1, 'b': 3 });
          })
          .then((_) {
            return _expectSyncMapWithDeltaMap(store, mapSync,
                { 'a' : null },
                { 'b': 3 });
          })
          .then((_) {
            return _expectSyncMapWithDeltaMap(store, mapSync,
                { 'b' : null },
                { });
          });

    });

    _testMapSync('simple remove', store, (MapSync mapSync) {

      expect(mapSync.map, isEmpty);

      return _expectSyncMapWithDeltaMap(store, mapSync,
          { 'a' : 1, 'b' : 2 },
          { 'a': 1, 'b' : 2 })
          .then((_) {
            return _expectSyncMapWithChange(store, mapSync,
                () => mapSync.map.remove('a'),
                { 'b': 2 });
          });
    });
});
}

Future _expectSyncMapWithDeltaMap(Storage store, MapSync mapSync, Map delta, Map expected) {
  return _expectSyncMapWithChange(store, mapSync, () {
    mapSync.map.addAll(delta);
  }, expected);
}

Future _expectSyncMapWithChange(Storage store, MapSync mapSync, void action(), Map expected) {
  var watcher = new EventWatcher<List<ChangeRecord>>();
  var sub = mapSync.changes.listen(watcher.handler);

  expect(mapSync.isUpdated, isTrue);

  action();

  expect(mapSync.isUpdated, isFalse);

  return watcher.listenOne()
      .then((List<ChangeRecord> records) {
        PropertyChangeRecord change = records.single;
        expect(change.field, const Symbol('isUpdated'));
        expect(mapSync.isUpdated, isFalse);

        return watcher.listenOne();
      })
      .then((List<ChangeRecord> records) {
        PropertyChangeRecord change = records.single;
        expect(change.field, const Symbol('isUpdated'));
        expect(mapSync.isUpdated, isTrue);

        return matchesMapValues(store, expected);
      })
      .whenComplete(sub.cancel);
}

void _testMapSync(String testName, Storage store, runner(MapSync store)) {
  test(testName, () {
    return MapSync.createAndLoad(store).then(runner);
  });
}
