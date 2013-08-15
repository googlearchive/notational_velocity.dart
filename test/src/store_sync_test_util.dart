library test.nv.store_sync_util;

import 'dart:async';
import 'dart:collection';
import 'package:unittest/unittest.dart';
import 'package:nv/src/storage.dart';

const VALID_VALUES = const {
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

Future expectStorageEmpty(Storage storage) {
  return storage.getKeys()
      .then((keys) {
        expect(keys, isEmpty);
      });
}

Future matchesValidValues(Storage storage) {
  return storage.getKeys()
    .then((List<String> keys) {
      expect(keys, unorderedEquals(VALID_VALUES.keys));

      return Future.forEach(keys, (k) {
        return storage.get(k)
            .then((dynamic value) {
              expect(value, VALID_VALUES[k]);
            });
      });
    });
}


Future asyncExpect(Future asyncValue, dynamic matches) {
  return asyncValue
      .then((value) {
        expect(value, matches);
      });
}

class EventWatcher<T> {
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
