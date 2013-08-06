import 'dart:html';
import 'package:mdv/mdv.dart' as mdv;
import 'package:nv/nv.dart';

void main() {
  mdv.initialize();

  var model = new AppModel();

  query('#app').model = model;
  query('#debug').model = model;
}
