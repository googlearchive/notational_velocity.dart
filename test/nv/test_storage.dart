library test.nv.storage;

import 'package:unittest/unittest.dart';
import 'package:nv/src/storage.dart';

void main([Storage storage]) {
  if(storage == null) {
    storage = new StringStorage.memory();
  }

  group('store values', () {
    const key = 'test_key';

    setUp(() {
      return storage.clear();
    });

    for(var description in _validValues.keys) {
      var testValue = _validValues[description];

      test(description, () {

        return storage.get(key)
            .then((value) {
              expect(value, isNull);

              return storage.set(key, testValue);
            })
            .then((_) {
              return storage.get(key);
            })
            .then((dynamic value) {
              expect(value, testValue);

              return storage.remove(key);
            })
            .then((dynamic value) {
              return storage.get(key);
            })
            .then((value) {
              expect(value, isNull);
            });
      });
    }
  });
}

const _validValues = const {
  'null': null,
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
