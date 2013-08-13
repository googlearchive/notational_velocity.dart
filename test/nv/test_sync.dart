library test.nv.sync;

import 'dart:async';
import 'dart:collection';
import 'package:observe/observe.dart';
import 'package:unittest/unittest.dart';
import 'package:nv/src/storage.dart';
import 'package:nv/src/sync.dart';

void main(Storage store) {
  group('sync', () {

    setUp(() {
      return store.clear();
    });

    test('create', () {

      return store.addAll(_validValues)
          .then((_) => MapSync.create(store))
          .then((ms) {
            expect(ms.map, equals(_validValues));
            expect(ms.updated, isTrue);
          });
    });

    _testMapSync('simple set', store, (MapSync mapSync) {

      var watcher = new _EventWatcher<List<ChangeRecord>>();
      mapSync.changes.listen(watcher.handler);

      expect(mapSync.map, isEmpty);

      mapSync.map['a'] = 1;
      expect(mapSync.updated, isFalse);

      return watcher.listenOne()
          .then((List<ChangeRecord> records) {
            PropertyChangeRecord change = records.single;
            expect(change.field, const Symbol('updated'));
          });

      // wait on update change event

      // set one

      // - updated is false

      // on updated prop change
      // updated is true
      // value is seen in source storage

    });

  });
}

class _EventWatcher<T> {
  final Queue<T> _events = new Queue<T>();

  Completer<T> _listenCompleter;
  int _eventCount = 0;

  int get pendingEventCount => _events.length;

  List<T> clearPending() {
    var items = _events.toList();
    _events.clear();
    return items;
  }

  int get eventCount => _eventCount;

  void handler(T args) {
    _events.add(args);
    _eventCount++;

    if(_listenCompleter != null) {
      var completer = _listenCompleter;
      _listenCompleter = null;
      Timer.run(()  => completer.complete(_getSingleEvent()));
    }
  }

  Future<T> listenOne() {
    assert(_listenCompleter == null);
    if(_events.isEmpty) {
      _listenCompleter = new Completer();
      return _listenCompleter.future;
    }

    return new Future(_getSingleEvent);
  }

  T _getSingleEvent() {
    var items = clearPending();
    assert(items.length == 1);
    return items.single;
  }
}

void _testMapSync(String testName, Storage store, runner(MapSync store)) {
  test(testName, () {
    return MapSync.create(store).then(runner);
  });
}

const _validValues = const {
  'string': 'a string',
  'int': 42,
  'double': 3.1415,
  'array': const [1,2,3,4],
  'map': const {
    'int': 42,
    'array': const [1,2,3],
    'map': const { 'a':1, 'b':2}
  }
};
