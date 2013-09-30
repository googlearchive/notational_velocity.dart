library nv.elements.note_row;

import 'dart:html';
import 'package:polymer/polymer.dart';

import 'package:nv/src/models.dart';
import 'package:nv/src/shared.dart';

@CustomTag('note-row-element')
class NoteRowElement extends PolymerElement with ChangeNotifierMixin {
  bool get applyAuthorStyles => true;

  Selectable<Note> _value;

  Selectable<Note> get value => _value;

  void set value(Selectable<Note> value) {
    _value = value;
    _notifyPropChange(const Symbol('value'));
    _notifyPropChange(const Symbol('note'));
  }

  Note get note => (_value == null) ? null : _value.value;

  void created() {
    super.created();
    Element.clickEvent.forTarget(this).listen(_handleClick);
  }

  void _handleClick(MouseEvent e) {
    e.preventDefault();
    _value.isSelected = true;
  }

  void _notifyPropChange(Symbol field) {
    notifyChange(new PropertyChangeRecord(field));
  }

}
