import 'package:polymer/polymer.dart';
import 'package:nv/src/models.dart';
import 'package:nv/debug.dart';

import 'package:nv/init.dart' as init;

@CustomTag('debug-element')
class DebugElement extends PolymerElement {
  final DebugVM _vm;

  DebugElement() : _vm = new DebugVM(init.appModel);

  AppModel get appModel => _vm.appModel;
}
