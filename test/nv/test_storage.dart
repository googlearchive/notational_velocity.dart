library test.nv.storage;

import 'package:unittest/unittest.dart';
import 'package:nv/src/storage.dart';
import 'package:nv/debug.dart';

import 'test_app_controller.dart' as app_controller;
import 'test_note_list.dart' as note_list;
import 'test_sync.dart' as sync;
import '../src/store_sync_test_util.dart';

typedef Storage StorageFactory();

void testStorage(Map<String, StorageFactory> factories) {
  var allStores = new Map.from(factories);

  allStores['memory - sync'] = () => new StringStorage.memorySync();
  allStores['memory - async'] = () => new StringStorage.memoryAsync();
  allStores['memory - delayed - 10'] = () => new StringStorage.memoryDelayed(10);

  group('Storage', () {
    allStores.forEach((String storeName, StorageFactory factory) {
      group(storeName, () {

        _testCore(factory);
        _testNested(factory);
        sync.main(factory);
        app_controller.main(factory);
        note_list.main(factory);
      });
    });
  });

}

void _testNested(StorageFactory factory) {
  group('nested', () {
    Storage nestedFactory() {
      var storage = factory();
      return new NestedStorage(storage, 'test1');
    };

    _testCore(nestedFactory);

    test('independant', () {
      var storage = factory();
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

void _testCore(StorageFactory factory) {
  test('store pnp', () {
    var storage = factory();
    return storage.addAll(PNP)
      .then((_) {
        return matchesMapValues(storage, PNP);
      });
  });

  test('add many and clear', () {
    // the added null is a no-op
    final validValuesAndNull = new Map.from(VALID_VALUES);
    validValuesAndNull['null'] = null;

    var storage = factory();
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
    var storage = factory();
    return storage.getKeys()
        .then((List<String> keys) {
          expect(keys, isEmpty);

          return storage.addAll(VALID_VALUES);
        })
        .then((_) => matchesValidValues(storage));
  });

  test('setting null == removing', () {
    var storage = factory();
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

        var storage = factory();
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
