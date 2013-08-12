import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:nv/src/controllers.dart';
import 'package:nv/src/models.dart';
import 'package:nv/init.dart' as init;

@CustomTag('app-element')
class AppElement extends PolymerElement {
  bool get applyAuthorStyles => true;


  AppController get appModel => init.appModel;

  void handleNoteClick(Event e, var detail, Element target) {
    e.preventDefault();
    _noteClick(target.dataset['noteTitle']);
  }

  void _noteClick(String noteTitle) {

    var note = appModel.openOrCreateNote(noteTitle);
    _loadNote(note);
  }

  void _loadNote(Note note) {

  }

}
