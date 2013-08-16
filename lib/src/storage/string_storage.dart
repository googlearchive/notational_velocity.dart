part of nv.storage;

class StringStorage implements Storage {

  final Map<String, String> _store;

  factory StringStorage.memory() =>
      new StringStorage(new Map<String, String>());

  StringStorage(this._store) {
    assert(this._store != null);
  }

  @override
  Future set(String key, value) {
    if(value == null) return remove(key);

    return new Future(() {
      _store[key] = JSON.stringify(value);
    });
  }

  @override
  Future<dynamic> get (String key) {
    dynamic val = _store[key];

    if(val == null) {
      // should NEVER store null.
      assert(!_store.containsKey(key));
      return new Future.value(null);
    } else {
      return new Future(() => JSON.parse(val));
    }
  }

  @override
  Future remove(String key) {
    return new Future(() {
      _store.remove(key);
    });
  }

  @override
  Future clear() {
    return new Future(() {
      _store.clear();
    });
  }

  Future<bool> exists(String key) => new Future.value(_store.containsKey(key));

  Future<List<String>> getKeys() =>
    new Future(() => _store.keys.toList(growable: false));

  Future addAll(Map<String, dynamic> values) {
    return new Future(() {
      values.forEach((k, v) {
        if(v == null) {
          _store.remove(k);
        } else {
          _store[k] = JSON.stringify(v);
        }
      });
    });
  }
}
