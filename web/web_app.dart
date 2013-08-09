import 'dart:html';
import 'package:mdv/mdv.dart' as mdv;
import 'package:nv/nv.dart';

void main() {
  mdv.initialize();

  var storage = new StringStorage(window.sessionStorage);
  var model = new AppModel(storage);

  //_bootstrapPNP(model);

  query('#app').model = model;
  query('#debug').xtag.appModel = model;
}
