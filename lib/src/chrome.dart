library nv.chrome;

import 'dart:async';

import 'dart:js' as js;
import 'dart:json' as JSON;
import 'package:bot/bot.dart';
import 'package:chrome_gen/gen/storage.dart';
import 'storage.dart';

class PackagedStorage implements Storage {
  final StorageArea _area = storage.local;

  bool _isDisposed = false;

  bool get isDisposed => _isDisposed;

  Future clear() {
    _requireNotDisposed();
    return _area.clear();
  }

  Future set(String key, dynamic value) {
    _requireNotDisposed();
    if(value == null) return remove(key);

    var map = new Map<String, dynamic>()
        ..[key] = JSON.stringify(value);

    return _area.set(map);
  }

  Future<dynamic> get(String key) {
    return _get(key)
        .then((String jsonString) {
          var val = (jsonString == null) ? null : JSON.parse(jsonString);
          return val;
      });
  }

  Future<bool> exists(String key) =>
    _get(key).then((String jsonString) => jsonString != null);

  Future remove(String key) => _remove([key]);

  Future<List<String>> getKeys() {
    _requireNotDisposed();

    return _area.get(null)
        .then((Map<String, dynamic> map) {
          return map.keys.toList();
        });
  }

  Future addAll(Map<String, dynamic> values) {
    _requireNotDisposed();
    var map = new Map<String, dynamic>();
    var removes = [];
    values.forEach((k, v) {
      if(v == null) {
        removes.add(k);
      } else {
        map[k] = JSON.stringify(v);
      }
    });

    return _remove(removes)
        .then((_) {
          return _area.set(map);
        });
  }

  void dispose() {
    _requireNotDisposed();
    _isDisposed = true;
  }

  //
  // Implementation
  //

  void _requireNotDisposed() {
    if(_isDisposed) {
      throw new DisposedError();
    }
  }

  Future<String> _get(String key) {
    _requireNotDisposed();

    return _area.get(key)
        .then((Map<String, dynamic> values) {
          return values[key];
        });
  }

  Future _remove(List<String> keys) {
    _requireNotDisposed();
    if(keys.isEmpty) return new Future.value(null);

    return _area.remove(js.jsify(keys));
  }

}
