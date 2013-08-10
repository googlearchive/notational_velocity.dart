library test.nv.storage;

import 'dart:async';
import 'package:unittest/unittest.dart';
import 'package:nv/src/storage.dart';

import 'package:nv/debug.dart';

void testStorage(Map<String, Storage> stores) {
  group('Storage', () {
    stores.forEach((String storeName, Storage store) {
      group(storeName, () {
        main(store);
        testNested(store);
      });
    });
  });

}

void testNested(Storage storage) {
  group('nested', () {
    main(new NestedStorage(storage, ['test1']));

    test('independant', () {
      var n1 = new NestedStorage(storage, ['t1']);
      var n2 = new NestedStorage(storage, ['t2']);

      return n1.addAll(_validValues)
          .then((_) => _matchesValidValues(n1))
          .then((_) => _isEmpty(n2))
          .then((_) => n2.addAll(_validValues))
          .then((_) => _matchesValidValues(n1))
          .then((_) => _matchesValidValues(n2))
          .then((_) => n1.clear())
          .then((_) => _isEmpty(n1))
          .then((_) => _matchesValidValues(n2))
          .then((_) => n2.clear())
          .then((_) => _isEmpty(n1))
          .then((_) => _isEmpty(n2));
    });
  });
}

void main(Storage storage) {
  setUp(() {
    return storage.clear();
  });

  test('store pnp', () {
      return storage.addAll(PNP)
        .then((_) {
          return storage.getKeys();
        })
        .then((List<String> keys) {
          expect(keys, unorderedEquals(PNP.keys));
        });
  });

  test('add many and clear', () {
    return storage.addAll(_validValues)
      .then((_) {
        return _matchesValidValues(storage);
      })
      .then((_) {
        return storage.clear();
      })
      .then((_) => _isEmpty(storage))
      .then((_) {
        return Future.forEach(_validValues.keys, (key) {
          return storage.get(key)
              .then((value) {
                expect(value, null);
              });
        });
      });
  });

  test('addAll, getKeys', () {
    return storage.getKeys()
        .then((List<String> keys) {
          expect(keys, isEmpty);

          return storage.addAll(_validValues);
        })
        .then((_) {
          return _matchesValidValues(storage);
        });
  });

  group('store values', () {
    const key = 'test_key';

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

Future _isEmpty(Storage storage) {
  return storage.getKeys()
      .then((keys) {
        expect(keys, isEmpty);
      });
}

Future _matchesValidValues(Storage storage) {
  return storage.getKeys()
    .then((List<String> keys) {
      expect(keys, unorderedEquals(_validValues.keys));

      return Future.forEach(keys, (k) {
        return storage.get(k)
            .then((dynamic value) {
              expect(value, _validValues[k]);
            });
      });
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
