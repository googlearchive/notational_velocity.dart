part of nv.storage;

/**
 * Wraps a storage object, but only gives access to a nested namespace
 */
class NestedStorage implements Storage {
  bool _isDisposed = false;

  final Storage _storage;
  final List<String> _rootKeys;

  NestedStorage(Storage storage, String path) :
    this._storage = _getRootStorage(storage),
    this._rootKeys = _getFullPath(storage, path) {
  }

  bool get isDisposed => _isDisposed || _storage.isDisposed;

  @override
  Future set(String key, value) =>
      _wrapDisposeCheck(() => _storage.set(_getKey(key), value));

  @override
  Future<dynamic> get (String key) =>
      _wrapDisposeCheck(() => _storage.get(_getKey(key)));

  @override
  Future<bool> exists(String key) =>
      _wrapDisposeCheck(() => _storage.exists(_getKey(key)));

  @override
  Future remove(String key) =>
      _wrapDisposeCheck(() => _storage.remove(_getKey(key)));


  @override
  Future clear() => _wrapDisposeCheck(() => getKeys()
        .then((List<String> keys) {
          return Future.forEach(keys, remove);
        }));

  Future<List<String>> getKeys() =>
      _wrapDisposeCheck(() =>
          _storage.getKeys()
            .then((List<String> keys) {

              return keys
                  .map(_matching)
                  .where((e) => e != null)
                  .toList(growable: false);
            }));

  Future addAll(Map<String, dynamic> values) {
    _requireNotDisposed();
    var newMap = new Map();
    values.forEach((k, v) {
      newMap[_getKey(k)] = v;
    });
    return _wrapDisposeCheck(() => _storage.addAll(newMap));
  }

  void dispose() {
    _requireNotDisposed();
    _isDisposed = true;
  }

  //
  // Implementation
  //

  Future _wrapDisposeCheck(Future action()) {
    _requireNotDisposed();
    return action().then((value) {
      _requireNotDisposed();
      return value;
    });
  }

  void _requireNotDisposed() {
    if(_isDisposed) {
      throw new DisposedError();
    }
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
      parent = (parent as NestedStorage)._storage;
    }
    return parent;
  }

  static List<String> _getFullPath(Storage parent, String path) {
    assert(parent != null);
    assert(path != null);
    assert(path.isNotEmpty);

    if(parent is NestedStorage) {
      return $((parent as NestedStorage)._rootKeys).concat([path]).toList(growable: false);
    } else {
      return [path];
    }
  }
}
