library nv.sync;

import 'dart:async';
import 'dart:convert';
import 'package:nv/src/storage.dart';

// 1) Assume underlying storage is "owned" by the created instance.
//    No changes underneath
// 2) Assume all values are json-able

class MapSync<E> {
  final Codec<E, dynamic> _codec;
  final _SyncMap<E> _map = new _SyncMap<E>();
  final Storage _storage;
  bool _updated = false;

  MapSync(this._storage, this._codec) {
    // TODO: start sync?
  }

  //
  // Properties
  //

  bool get updated => _updated;

  Map<String, E> get map => _map;

  //
  // Methods
  //

  static Future<MapSync> create(Storage storage, Codec codec) {
    var ms = new MapSync(storage, codec);

    // something to wait for initial sync?

    return ms;
  }


}

class _SyncMap<E> implements Map<String, E> {

}
