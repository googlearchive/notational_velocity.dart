import 'dart:html';
import 'package:polymer/polymer.dart';
//import 'package:nv/src/controllers.dart';

@CustomTag('editor-element')
class EditorElement extends PolymerElement {

  void handleContentEdit(Event e, var detail, Element target) {
    print([e, e.type, detail, target]);
  }

}
