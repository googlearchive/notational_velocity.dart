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
          .then((_) => MapSync.create(store))
          .then((ms) {
            expect(ms.map, equals(VALID_VALUES));
            expect(ms.updated, isTrue);
          });
    });

    _testMapSync('simple set', store, (MapSync mapSync) {

      expect(mapSync.map, isEmpty);

      return _expectSyncMapChange(store, mapSync,
          { 'a' : 1 },
          { 'a': 1 })
          .then((_) {
            return _expectSyncMapChange(store, mapSync,
                { 'b' : 2 },
                { 'a': 1, 'b': 2 });
          })
          .then((_) {
            return _expectSyncMapChange(store, mapSync,
                { 'b' : 3 },
                { 'a': 1, 'b': 3 });
          })
          .then((_) {
            return _expectSyncMapChange(store, mapSync,
                { 'a' : null },
                { 'b': 3 });
          })
          .then((_) {
            return _expectSyncMapChange(store, mapSync,
                { 'b' : null },
                { });
      });
    });
  });
}

Future _expectSyncMapChange(Storage store, MapSync mapSync, Map delta, Map expected) {
  var watcher = new EventWatcher<List<ChangeRecord>>();
  var sub = mapSync.changes.listen(watcher.handler);

  expect(mapSync.updated, isTrue);

  mapSync.map.addAll(delta);

  expect(mapSync.updated, isFalse);

  return watcher.listenOne()
      .then((List<ChangeRecord> records) {
        PropertyChangeRecord change = records.single;
        expect(change.field, const Symbol('updated'));
        expect(mapSync.updated, isFalse);

        return watcher.listenOne();
      })
      .then((List<ChangeRecord> records) {
        PropertyChangeRecord change = records.single;
        expect(change.field, const Symbol('updated'));
        expect(mapSync.updated, isTrue);

        return matchesMapValues(store, expected);
      })
      .whenComplete(sub.cancel);
}

void _testMapSync(String testName, Storage store, runner(MapSync store)) {
  test(testName, () {
    return MapSync.create(store).then(runner);
  });
}
