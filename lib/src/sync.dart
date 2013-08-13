library nv.sync;

import 'dart:async';
import 'dart:convert';
import 'dart:collection';
import 'package:nv/src/storage.dart';

// 1) Assume underlying storage is "owned" by the created instance.
//    No changes underneath
// 2) Assume all values are json-able

class MapSync<E> {
  final _Encoder<E, dynamic> _encode;
  final _Decoder<E, dynamic> _decode;
  final _SyncMap<E> _map = new _SyncMap<E>();
  final Storage _storage;
  bool _updated = false;

  MapSync._(this._storage, [Codec<E, dynamic> codec]) :
    _encode = (codec == null) ? _identity : codec.encode,
    _decode = (codec == null) ? _identity : codec.decode;

  //
  // Properties
  //

  bool get updated => _updated;

  Map<String, E> get map => _map;

  //
  // Methods
  //

  static Future<MapSync> create(Storage storage, [Codec codec]) {
    var ms = new MapSync._(storage, codec);

    return storage.getKeys()
        .then((List<String> keys) {
          return Future.forEach(keys, (String key) {
            return storage.get(key)
                .then((Object json) {
                  ms._set(key, json);
                });
          });

        })
        .then((_) {
          return ms;
        });
  }

  //
  // Impl
  //

  void _set(String key, Object json) {
    _map._set(key, _decode(json));
  }


}

class _SyncMap<E> extends HashMap<String, E> {

  void operator []=(String key, E value) {
    throw new UnimplementedError('need to get on this guy...');
  }

  void clear() {
    throw new UnimplementedError('not implemented clear yet');
  }

  // putIfAbsent
  E putIfAbsent(String key, E ifAbsent()) {
    throw new UnimplementedError('putIfAbsent');
  }

  // remove
  E remove(Object key) {
    throw new UnimplementedError('remove');
  }

  void _set(String key, E value) {
    super[key] = value;
  }
}

Object _identity(Object value) => value;

typedef T _Encoder<S, T>(S value);
typedef S _Decoder<S, T>(T value);
