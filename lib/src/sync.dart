library nv.sync;

import 'dart:async';
import 'dart:convert';
import 'dart:collection';

import 'package:bot/bot.dart';
import 'package:meta/meta.dart';
import 'package:observe/observe.dart';

import 'package:nv/src/storage.dart';

// 1) Assume underlying storage is "owned" by the created instance.
//    No changes underneath
// 2) Assume all values are json-able

class MapSync<E> extends ChangeNotifierBase {
  final _Encoder<E, dynamic> _encode;
  final _Decoder<E, dynamic> _decode;
  final _SyncMap<E> _map = new _SyncMap<E>();
  final Set<String> _dirtyKeys = new Set<String>();
  final Storage _storage;

  bool _syncActive = false;

  MapSync._(this._storage, [Codec<E, dynamic> codec]) :
    _encode = (codec == null) ? _identity : codec.encode,
    _decode = (codec == null) ? _identity : codec.decode {

    _map.onKeyChanged.listen(_onKeyDirty);
  }

  //
  // Properties
  //

  bool get updated => _dirtyKeys.isEmpty;

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

  void _onKeyDirty(String key) {
    var wasEmpty = _dirtyKeys.isEmpty;
    _dirtyKeys.add(key);

    if(wasEmpty) {
      _notifyChange(_UPDATED);
    }
    _sync();
  }

  void _sync() {
    if(!_syncActive) {
      _syncActive = true;
      Timer.run(_doSync);
    }
  }

  void _doSync() {
    assert(_syncActive);

    if(updated) {
      _notifyChange(_UPDATED);
      _syncActive = false;
      return;
    }

    var key = _dirtyKeys.first;

    var value = _encode(_map[key]);
    _storage.set(key, value)
      .then((_) {
        var removed = _dirtyKeys.remove(key);
        assert(removed);
        Timer.run(_doSync);
      });

    // TODO: if set fails, we don't have a very good way to handle it...
  }

  void _notifyChange(Symbol prop) {
    notifyChange(new PropertyChangeRecord(prop));
  }

  static const _UPDATED = const Symbol('updated');
}

class _SyncMap<E> extends HashMap<String, E> {
  final EventHandle<String> _keyChanged = new EventHandle<String>();

  @override
  void operator []=(String key, E value) {
    // TODO: check for an actual change at some point?

    _set(key, value);
    _keyChanged.add(key);
  }

  @override
  void clear() {
    throw new UnimplementedError('not implemented clear yet');
  }

  @override
  E putIfAbsent(String key, E ifAbsent()) {
    throw new UnimplementedError('putIfAbsent');
  }

  @override
  E remove(Object key) {
    var value = super.remove(key);
    _keyChanged.add(key);
    return value;
  }

  @override
  void addAll(Map<String, E> other) {
    other.forEach((k, v) {
      this[k] = v;
    });
  }

  Stream<String> get onKeyChanged => _keyChanged.stream;

  //
  // Implementation
  //

  void _set(String key, E value) {
    super[key] = value;
  }
}

Object _identity(Object value) => value;

typedef T _Encoder<S, T>(S value);
typedef S _Decoder<S, T>(T value);
