library nv.web.init;

import 'dart:async';
import 'package:logging/logging.dart';
import 'package:polymer/polymer.dart';

import 'package:nv/src/chrome.dart' as chrome;
import 'package:nv/init.dart' as init;
import 'package:nv/src/controllers.dart';
import 'package:nv/src/storage.dart';


@initMethod
void _initmain() {
  //
  // Wire up logging
  //
  Logger.root.onRecord.listen((LogRecord record) {
    print([record.time, record.loggerName, record.message]);
  });

  Logger.root.info('\t**\tStarting\t**\t');


  _getDebugController().then((AppController ac) {
    init.populateController(ac);
  });
}

Future<AppController> _getDebugController() {
  var rootStorage = new chrome.PackagedStorage();

  var nestedStorage = new NestedStorage(rootStorage, 'nv_v0.0.2');

  return AppController.init(nestedStorage);
}


@CustomTag('init-element')
class InitElement extends PolymerElement { }
