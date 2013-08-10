library nv.storage;

import 'dart:async';
import 'dart:json' as JSON;
import 'package:meta/meta.dart';
import 'package:bot/bot.dart';

// TODO: consider moving this to bot_web -> share w/ PPW

/**
 * By convention, the only supported value types should be JSON-serializable
 */
abstract class Storage {

  Future set(String key, value);

  Future<dynamic> get(String key);

  Future remove(String key);

  Future clear();

  Future<List<String>> getKeys();

  Future addAll(Map<String, dynamic> values);
}


/**
 * Wraps a storage object, but only gives access to a nested namespace
 */
class NestedStorage implements Storage {
  final Storage _storage;
  final List<String> _rootKeys;

  NestedStorage(this._storage, [List<String> rootKeys]) :
    _rootKeys = (rootKeys == null) ? [] : rootKeys {
    assert(this._storage != null);

    for(var k in _rootKeys) {
      assert(k != null);
      assert(k.isNotEmpty);
    }
  }


  @override
  Future set(String key, value) => _storage.set(_getKey(key), value);

  @override
  Future<dynamic> get (String key) => _storage.get(_getKey(key));

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

  static List<String> _getPath(String input) {
    var uri = new Uri(path: input);
    return uri.pathSegments;
  }

  String _getKey(String key) =>
      new Uri(pathSegments: $(_rootKeys).concat([key]).toList(growable: false)).path;
}

class StringStorage implements Storage {

  final Map<String, String> _store;

  factory StringStorage.memory() =>
      new StringStorage(new Map<String, String>());

  StringStorage(this._store) {
    assert(this._store != null);
  }

  @override
  Future set(String key, value) {
    String val = JSON.stringify(value);

    return new Future(() {
      _store[key] = val;
    });
  }

  @override
  Future<dynamic> get (String key) {
    dynamic val = _store[key];

    if(val == null) {
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

  Future<List<String>> getKeys() =>
    new Future(() => _store.keys.toList(growable: false));

  Future addAll(Map<String, dynamic> values) {
    return new Future(() {
      values.forEach((k, v) {
        _store[k] = JSON.stringify(v);
      });
    });
  }
}
