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

// TODO: some kind of dispose?
//   ensure sync happens
//   kill off key change event listener

class MapSync<E> extends ChangeNotifierBase implements Loadable {
  final _Encoder<E, dynamic> _encode;
  final _Decoder<E, dynamic> _decode;
  final _SyncMap<E> _map = new _SyncMap<E>();
  final Set<String> _dirtyKeys = new Set<String>();
  final Storage _storage;

  Completer _loadCompleter;
  bool _syncActive = false;

  MapSync(this._storage, [Codec<E, dynamic> codec]) :
    _encode = (codec == null) ? _identity : codec.encode,
    _decode = (codec == null) ? _identity : codec.decode {

    _map.onKeyChanged.listen(_onKeyDirty);
  }

  //
  // Properties
  //

  LoadState get loadState => (_loadCompleter == null) ? LoadState.UNLOADED :
    (_loadCompleter.isCompleted) ? LoadState.LOADED : LoadState.LOADING;

  bool get isLoaded => loadState == LoadState.LOADED;

  bool get isUpdated => isLoaded && _dirtyKeys.isEmpty;

  Map<String, E> get map => isLoaded ? _map : const {};

  //
  // Methods
  //

  Future load() {
    if(_loadCompleter == null) {
      _doLoad();
    }

    return _loadCompleter.future;
  }

  static Future<MapSync> createAndLoad(Storage storage, [Codec codec]) {
    var ms = new MapSync(storage, codec);

    return ms.load()
        .then((_) => ms);
  }

  //
  // Impl
  //

  void _doLoad() {
    assert(_loadCompleter == null);
    _loadCompleter = new Completer();
    _notifyChange(const Symbol('isLoaded'));
    _notifyChange(const Symbol('loadState'));

    _storage.getKeys()
      .then((List<String> keys) {
        return Future.forEach(keys, (String key) {
          return _storage.get(key)
              .then((Object json) {
                _set(key, json);
              });
        });

      })
      .then((_) {
        _loadCompleter.complete();
        _notifyChange(const Symbol('isLoaded'));
        _notifyChange(const Symbol('loadState'));
      });
  }

  void _set(String key, Object json) {
    _map._set(key, _decode(json));
  }

  void _onKeyDirty(String key) {
    var wasEmpty = _dirtyKeys.isEmpty;
    _dirtyKeys.add(key);

    if(wasEmpty) {
      _notifyChange(_IS_UPDATED);
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

    if(isUpdated) {
      _notifyChange(_IS_UPDATED);
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

  static const _IS_UPDATED = const Symbol('isUpdated');
}

class LoadState {
  final String _msg;

  static const LoadState UNLOADED = const LoadState._('unloaded');
  static const LoadState LOADING = const LoadState._('loading');
  static const LoadState LOADED = const LoadState._('loaded');

  const LoadState._(this._msg);

  @override
  String toString() => _msg;
}

abstract class Loadable implements Observable {
  Future load();
  LoadState get loadState;
  bool get isLoaded;
}

class _SyncMap<E> extends LinkedHashMap<String, E> {
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
