library test.nv.sync;

import 'dart:async';
import 'package:unittest/unittest.dart';
import 'package:nv/src/storage.dart';
import 'package:nv/src/sync.dart';
import 'package:nv/src/models.dart';
import 'package:nv/src/serialization.dart';

void main(Storage store) {
  group('sync', () {

  });
}



Future<MapSync<Note>> _getSync(Storage store) =>
    MapSync.create(store, NOTE_CODEC);
