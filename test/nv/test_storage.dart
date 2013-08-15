library test.nv.storage;

import 'dart:async';
import 'package:unittest/unittest.dart';
import 'package:nv/src/storage.dart';
import 'package:nv/debug.dart';

import '../src/store_sync_test_util.dart';

void testStorage(Map<String, Storage> stores) {
  group('Storage', () {
    stores.forEach((String storeName, Storage store) {
      group(storeName, () {

        setUp(() {
          return store.clear();
        });

        _testCore(store);
        _testNested(store);
      });
    });
  });

}

void _testNested(Storage storage) {
  group('nested', () {
    _testCore(new NestedStorage(storage, 'test1'));

    test('independant', () {
      var n1 = new NestedStorage(storage, 't1');
      var n11 = new NestedStorage(n1, 't11');
      var n2 = new NestedStorage(storage, 't2');

      return n1.addAll(VALID_VALUES)
          .then((_) => matchesValidValues(n1))
          .then((_) => expectStorageEmpty(n11))
          .then((_) => expectStorageEmpty(n2))
          .then((_) => n2.addAll(VALID_VALUES))
          .then((_) => n11.addAll(VALID_VALUES))
          .then((_) => matchesValidValues(n1))
          .then((_) => matchesValidValues(n2))
          .then((_) => matchesValidValues(n11))
          .then((_) => n1.clear())
          .then((_) => expectStorageEmpty(n1))
          .then((_) => matchesValidValues(n2))
          .then((_) => n2.clear())
          .then((_) => expectStorageEmpty(n1))
          .then((_) => expectStorageEmpty(n2))
          .then((_) => matchesValidValues(n11))
          .then((_) => n11.clear())
          .then((_) => expectStorageEmpty(n11));
    });
  });
}

void _testCore(Storage storage) {
  test('store pnp', () {
      return storage.addAll(PNP)
        .then((_) {
          return matchesMapValues(storage, PNP);
        });
  });

  test('add many and clear', () {
    // the added null is a no-op
    final validValuesAndNull = new Map.from(VALID_VALUES);
    validValuesAndNull['null'] = null;

    return storage.addAll(validValuesAndNull)
      .then((_) {
        return matchesValidValues(storage);
      })
      .then((_) {
        return storage.clear();
      })
      .then((_) => expectStorageEmpty(storage));
  });

  test('addAll, getKeys', () {
    return storage.getKeys()
        .then((List<String> keys) {
          expect(keys, isEmpty);

          return storage.addAll(VALID_VALUES);
        })
        .then((_) => matchesValidValues(storage));
  });

  test('setting null == removing', () {
    return storage.exists('a')
        .then((bool exists) {
          expect(exists, isFalse);

          return storage.get('a');
        })
        .then((val) {
          expect(val, isNull);

          return storage.set('a', null);
        })
        .then((_) {
          return storage.exists('a');
        })
        .then((bool exists) {
          expect(exists, isFalse);

          return storage.get('a');
        })
        .then((val) {
          expect(val, isNull);
        });
  });

  group('store values', () {
    const key = 'test_key';

    for(var description in VALID_VALUES.keys) {
      var testValue = VALID_VALUES[description];

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
              return storage.exists(key);
            })
            .then((bool value) {
              expect(value, isFalse);
            });
      });
    }
  });
}
