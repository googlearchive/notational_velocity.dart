library nv.storage;

import 'dart:async';
import 'dart:json' as JSON;
import 'package:meta/meta.dart';

// TODO: consider moving this to bot_web -> share w/ PPW

abstract class Storage {

  Future set(String key, value);

  Future<dynamic> get(String key);

  Future remove(String key);

  Future clear();
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

    return new Future.sync(() {
      _store[key] = val;
    });
  }

  @override
  Future<dynamic> get (String key) {
    dynamic val = _store[key];

    if(val == null) {
      return new Future.value(null);
    } else {
      return new Future.sync(() => JSON.parse(val));
    }
  }

  @override
  Future remove(String key) {
    return new Future.sync(() {
      _store.remove(key);
    });
  }

  @override
  Future clear() {
    return new Future.sync(() {
      _store.clear();
    });
  }
}
