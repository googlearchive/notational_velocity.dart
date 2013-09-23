import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:nv/src/controllers.dart';
import 'package:nv/debug.dart';

import 'package:nv/init.dart' as init;

@CustomTag('debug-element')
class DebugElement extends PolymerElement with ChangeNotifierMixin {

  bool get applyAuthorStyles => true;

  DebugController _vm;

  DebugElement() {
    init.controllerFuture.then((AppController controller) {
      _vm = new DebugController(controller);
      notifyChange(new PropertyChangeRecord(const Symbol('controller')));
    });
  }

  AppController get controller => (_vm == null) ? null : _vm.controller;

  void _reset(Event e, var detail, ButtonElement target) {
    window.localStorage.clear();
    window.location.reload();
  }
}
