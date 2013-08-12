import 'dart:html';
import 'package:polymer/polymer.dart';
import 'interfaces.dart';

@CustomTag('editor-element')
class EditorElement extends PolymerElement implements EditorInterface {

  String get value => _root.text;

  void set value(String val) {
    _root.text = val;
  }

  Element get _root => shadowRoot.query('#root');

  void handleContentEdit(Event e, var detail, Element target) {
    print([e, e.type, detail, target]);
  }

}
