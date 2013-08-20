import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:nv/src/controllers.dart';
import 'package:nv/src/models.dart';
import 'package:nv/init.dart' as init;
import 'package:nv/elements/interfaces.dart';

@CustomTag('app-element')
class AppElement extends PolymerElement with ChangeNotifierMixin {
  bool get applyAuthorStyles => true;

  AppController _controller;

  AppController get controller => _controller;

  AppElement() {
    init.controllerFuture.then((AppController value) {
      assert(_controller == null);
      _controller = value;
      notifyChange(new PropertyChangeRecord(const Symbol('controller')));
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

    var value = content.value;

    _editor.enabled = true;
    _editor.text = value;
  }

  EditorInterface get _editor => shadowRoot.query('editor-element').xtag;

}
