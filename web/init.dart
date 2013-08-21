library nv.web.init;

import 'dart:async';
import 'dart:html';
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
  var rootStorage = new StringStorage(window.localStorage);

  var nestedStorage = new NestedStorage(rootStorage, 'nv_v0.0.1');

  return MapSync.createAndLoad(nestedStorage, NOTE_CODEC)
    .then(_initAppController);
}

AppController _initAppController(MapSync<Note> noteMap) {

  var controller = new AppController(noteMap);

  window.onKeyDown
    .where((KeyboardEvent e) => e.keyCode == KeyCode.ESC)
    .listen((KeyboardEvent e) {
      controller.resetSearch();
    });

  return controller;
}


@CustomTag('init-element')
class InitElement extends PolymerElement { }
