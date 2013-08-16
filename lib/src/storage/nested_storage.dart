part of nv.storage;

/**
 * Wraps a storage object, but only gives access to a nested namespace
 */
class NestedStorage implements Storage {
  final Storage _storage;
  final List<String> _rootKeys;

  NestedStorage(Storage storage, String path) :
    this._storage = _getRootStorage(storage),
    this._rootKeys = _getFullPath(storage, path) {
  }

  @override
  Future set(String key, value) => _storage.set(_getKey(key), value);

  @override
  Future<dynamic> get (String key) => _storage.get(_getKey(key));

  @override
  Future<bool> exists(String key) => _storage.exists(_getKey(key));

  @override
  Future remove(String key) => _storage.remove(_getKey(key));

  @override
  Future clear() => getKeys()
        .then((List<String> keys) {
          return Future.forEach(keys, remove);
        });

  Future<List<String>> getKeys() {
    return _storage.getKeys()
        .then((List<String> keys) {

          return keys
              .map(_matching)
              .where((e) => e != null)
              .toList(growable: false);
        });
  }

  Future addAll(Map<String, dynamic> values) {
    var newMap = new Map();
    values.forEach((k, v) {
      newMap[_getKey(k)] = v;
    });
    return _storage.addAll(newMap);
  }

  String _matching(String rawKey) {
    var keyPath = _getPath(rawKey);

    if(keyPath.length != _rootKeys.length + 1) return null;

    for(var i = 0; i < _rootKeys.length; i++) {
      if(_rootKeys[i] != keyPath[i]) return null;
    }

    return keyPath.last;
  }


  String _getKey(String key) =>
      new Uri(pathSegments: $(_rootKeys).concat([key]).toList(growable: false)).path;

  static List<String> _getPath(String input) {
    var uri = new Uri(path: input);
    return uri.pathSegments;
  }

  static Storage _getRootStorage(Storage parent) {
    assert(parent != null);
    while(parent is NestedStorage) {
      parent = parent._storage;
    }
    return parent;
  }

  static List<String> _getFullPath(Storage parent, String path) {
    assert(parent != null);
    assert(path != null);
    assert(path.isNotEmpty);

    if(parent is NestedStorage) {
      return $(parent._rootKeys).concat([path]).toList(growable: false);
    } else {
      return [path];
    }
  }
}
