import 'dart:html';
import 'package:polymer/polymer.dart';

import 'package:nv/src/models.dart';
import 'package:nv/src/controllers.dart';

@CustomTag('note-row-element')
class NoteRowElement extends PolymerElement with ChangeNotifierMixin {
  bool get applyAuthorStyles => true;

  NoteController _note;
  Note _selectedNote;

  NoteController get note => _note;

  void set note(NoteController value) {
    _note = value;
    _notifyPropChange(const Symbol('note'));
  }

  Note get selectedNote => _selectedNote;

  void set selectedNote(Note value) {
    _selectedNote = value;
    _notifyPropChange(const Symbol('selectedNote'));
  }

  void handleClick(Event e, var detail, Element target) {
    e.preventDefault();
    _note.requestSelect();
  }

  void _notifyPropChange(Symbol field) {
    notifyChange(new PropertyChangeRecord(field));
  }

}
