library nv.web.init;

import 'dart:async';
import 'package:polymer/polymer.dart';

import 'package:nv/init.dart' as init;
import 'package:nv/src/controllers.dart';
import 'package:nv/src/models.dart';
import 'package:nv/src/serialization.dart';
import 'package:nv/src/storage.dart';
import 'package:nv/src/sync.dart';


@initMethod
void _initmain() {
  _getDebugController().then((AppController ac) {
    init.populateController(ac);
  });
}

Future<AppController> _getDebugController() {
  var storage = new StringStorage.memoryDelayed();

  return MapSync.createAndLoad(storage, NOTE_CODEC)
    .then((MapSync<Note> ms) => new AppController(ms));
}


@CustomTag('init-element')
class InitElement extends PolymerElement { }
