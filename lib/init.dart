library nv.init;

import 'package:nv/src/controllers.dart';

AppController get appModel {
  assert(_appModel != null);
  return _appModel;
}

void initAppModel(AppController value) {
  assert(_appModel == null);
  assert(value != null);
  _appModel = value;
}

AppController _appModel;
