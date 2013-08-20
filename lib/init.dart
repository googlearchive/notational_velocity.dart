library nv.init;

import 'dart:async';
import 'package:nv/src/controllers.dart';

Future<AppController> get controllerFuture => _controllerCompleter.future;

void populateController(AppController value) {
  assert(!_controllerCompleter.isCompleted);
  _controllerCompleter.complete(value);
}

Completer<AppController> _controllerCompleter =
  new Completer<AppController>();
