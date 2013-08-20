import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:nv/src/controllers.dart';
import 'package:nv/src/models.dart';
import 'package:nv/init.dart' as init;
import 'package:nv/elements/interfaces.dart';

@CustomTag('app-element')
class AppElement extends PolymerElement {
  bool get applyAuthorStyles => true;

  AppController _controller;

  AppController get controller => _controller;

  AppElement() {
    init.controllerFuture.then((AppController value) {
      assert(_controller == null);
      _controller = value;
    });
  }

  void handleNoteClick(Event e, var detail, Element target) {
    e.preventDefault();
    _noteClick(target.dataset['noteTitle']);
  }

  void _noteClick(String noteTitle) {
    var note = controller.openOrCreateNote(noteTitle);
    _loadNote(note);
  }

  void _loadNote(Note note) {
    assert(note.content is TextContent);

    TextContent content = note.content;

    EditorInterface editor = _editor.xtag;

    var value = content.value;

    editor.enabled = true;
    editor.text = value;
  }

  Element get _editor => shadowRoot.query('editor-element');

}
