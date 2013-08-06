import 'dart:html';
import 'package:mdv/mdv.dart' as mdv;
import 'package:nv/nv.dart';
import '../test/data/pride_and_prejudice.dart';

void main() {
  mdv.initialize();

  var model = new AppModel();

  _bootstrapPNP(model);

  query('#app').model = model;
  query('#debug').model = model;
}

void _bootstrapPNP(AppModel model) {

  PNP.forEach((String chapter, String content) {
    model.notes.add(new Note(chapter, new TextContent(content)));
  });
}
