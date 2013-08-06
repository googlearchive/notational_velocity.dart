import 'dart:html';
import 'package:mdv/mdv.dart' as mdv;
import 'package:nv/nv.dart';

void main() {
  mdv.initialize();

  query('#app').model = new AppModel();
}
