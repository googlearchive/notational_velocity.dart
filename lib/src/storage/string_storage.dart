part of nv.storage;

const _slowDelay = const Duration(milliseconds: 10);

Future _slowRunner(task()) =>
  new Future.delayed(_slowDelay, task);

class StringStorage implements Storage {

  final Function _runner;

  final Map<String, String> _store;

  factory StringStorage.memory([runner() = null]) =>
      new StringStorage(new Map<String, String>(), runner);

  StringStorage(this._store, [runner() = null]) :
    this._runner = (runner == null) ? _slowRunner : runner {
    assert(this._store != null);
  }

  @override
  Future set(String key, value) {
    if(value == null) return remove(key);

    return _runner(() {
      _store[key] = JSON.stringify(value);
    });
  }

  @override
  Future<dynamic> get (String key) {
    dynamic val = _store[key];

    if(val == null) {
      // should NEVER store null.
      assert(!_store.containsKey(key));
      return _runner(() => null);
    } else {
      return _runner(() => JSON.parse(val));
    }
  }

  @override
  Future remove(String key) {
    return _runner(() {
      _store.remove(key);
    });
  }

  @override
  Future clear() {
    return _runner(() {
      _store.clear();
    });
  }

  Future<bool> exists(String key) => new Future.value(_store.containsKey(key));

  Future<List<String>> getKeys() =>
      _runner(() => _store.keys.toList(growable: false));

  Future addAll(Map<String, dynamic> values) {
    return _runner(() {
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
