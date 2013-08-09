library nv.init;

import 'package:nv/src/models.dart';

AppModel get appModel {
  assert(_appModel != null);
  return _appModel;
}

void initAppModel(AppModel value) {
  assert(_appModel == null);
  assert(value != null);
  _appModel = value;
}

AppModel _appModel;
