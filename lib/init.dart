library nv.init;

import 'dart:html';
import 'package:nv/src/models.dart';
import 'package:nv/src/storage.dart';

AppModel get appModel {
  if(_appModel == null) {
    var storage = new StringStorage(window.sessionStorage);
    _appModel = new AppModel(storage);
  }
  return _appModel;
}

AppModel _appModel;
