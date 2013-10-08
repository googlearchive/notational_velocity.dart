library nv.web.init;

import 'dart:async';
import 'dart:html';
import 'package:logging/logging.dart';

import 'package:nv/init.dart' as init;
import 'package:nv/src/controllers.dart';
import 'package:nv/src/storage.dart';


void main() {
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
  var rootStorage = new StringStorage(window.localStorage);

  var nestedStorage = new NestedStorage(rootStorage, 'nv_v0.0.2');

  return AppController.init(nestedStorage);
}
