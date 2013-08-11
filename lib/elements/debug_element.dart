import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:nv/src/controllers.dart';
import 'package:nv/debug.dart';

import 'package:nv/init.dart' as init;

@CustomTag('debug-element')
class DebugElement extends PolymerElement {
  bool get applyAuthorStyles => true;

  final DebugVM _vm;

  DebugElement() : _vm = new DebugVM(init.appModel);

  AppController get appModel => _vm.appModel;


  void populate(Event e, var detail, ButtonElement target) {
    assert(!target.disabled);
    target.disabled = true;
    _vm.populate()
      .whenComplete(() {
        target.disabled = false;
      });
  }
}
