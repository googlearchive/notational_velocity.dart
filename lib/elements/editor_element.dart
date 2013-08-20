import 'dart:html';
import 'package:polymer/polymer.dart';
import 'interfaces.dart';

@CustomTag('editor-element')
class EditorElement extends PolymerElement
  with ChangeNotifierMixin implements EditorInterface {

  bool _enabled = false;

  //
  // Properties
  //

  bool get enabled => _enabled;

  void set enabled(bool value) {
    if(value != _enabled) {
      if(!value) {
        text = '';
      }

      _enabled = value;
      _notifyPropChange(const Symbol('enabled'));

    }
  }

  String get text => (_root == null) ? '' : _root.text;

  void set text(String val) {
    assert(enabled);
    _root.text = val;
    _notifyPropChange(const Symbol('text'));
  }

  //
  // Nested event handlers
  //

  void handleContentEdit(Event e, var detail, Element target) {
    assert(_enabled);
    _notifyPropChange(const Symbol('text'));
  }

  //
  // Implementatino
  //

  Element get _root => shadowRoot.query('#root');

  void _notifyPropChange(Symbol prop) {
    notifyChange(new PropertyChangeRecord(prop));
  }
}
