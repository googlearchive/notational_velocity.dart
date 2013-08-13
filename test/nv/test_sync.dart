library test.nv.sync;

import 'dart:async';
import 'package:unittest/unittest.dart';
import 'package:nv/src/storage.dart';
import 'package:nv/src/sync.dart';
import 'package:nv/src/models.dart';
import 'package:nv/src/serialization.dart';

void main(Storage store) {
  group('sync', () {

    setUp(() {
      return store.clear();
    });

    test('create', () {

      store.addAll(_validValues);
      return MapSync.create(store)
          .then((ms) {
            expect(ms.map, equals(_validValues));
          });
    });

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
