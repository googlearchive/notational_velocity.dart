import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:nv/src/controllers.dart';
import 'package:nv/debug.dart';

import 'package:nv/init.dart' as init;

@CustomTag('debug-element')
class DebugElement extends PolymerElement with ChangeNotifierMixin {

  bool get applyAuthorStyles => true;

  DebugVM _vm;

  DebugElement() {
    init.controllerFuture.then((AppController controller) {
      _vm = new DebugVM(controller);
      notifyChange(new PropertyChangeRecord(const Symbol('controller')));
    });
  }

  AppController get controller => (_vm == null) ? null : _vm.controller;

  void populate(Event e, var detail, ButtonElement target) {
    assert(!target.disabled);
    target.disabled = true;
    _vm.populate()
      .whenComplete(() {
        target.disabled = false;
      });
  }
}
