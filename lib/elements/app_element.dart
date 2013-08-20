import 'dart:html';
import 'package:meta/meta.dart';
import 'package:polymer/polymer.dart';
import 'package:nv/init.dart' as init;
import 'package:nv/elements/interfaces.dart';
import 'package:nv/src/controllers.dart';
import 'package:nv/src/models.dart';
import 'package:nv/src/shared.dart';

@CustomTag('app-element')
class AppElement extends PolymerElement with ChangeNotifierMixin {
  bool get applyAuthorStyles => true;

  bool _childEventsWired = false;
  AppController _controller;
  Note _currentNote;

  AppController get controller => _controller;

  AppElement() {
    init.controllerFuture.then((AppController value) {
      assert(_controller == null);
      _controller = value;
      notifyChange(new PropertyChangeRecord(const Symbol('controller')));
    });
  }

  //
  // Overrides
  //

  @override
  void inserted() {
    assert(!_childEventsWired);

    // TODO: hold on to the subscription. Tear down at some point?
    filterPropertyChangeRecords(_editor, const Symbol('text'))
      .listen(_editorTextChanged);

    _childEventsWired = true;
  }

  //
  // Event handlers
  //

  void handleNoteClick(Event e, var detail, Element target) {
    e.preventDefault();
    _noteClick(target.dataset['noteTitle']);
  }

  //
  // Implementation
  //

  void _editorTextChanged(_) {
    var title = _currentNote.title;
    var noteContent = new TextContent(_editor.text);
    _controller.updateNote(title, noteContent);
  }

  void _noteClick(String noteTitle) {
    var note = controller.openOrCreateNote(noteTitle);
    _loadNote(note);
  }

  void _loadNote(Note note) {
    if(_currentNote != null) {
      throw new UnimplementedError('tbd');
    }
    assert(note.content is TextContent);

    _currentNote = note;

    TextContent content = note.content;

    var value = content.value;

    _editor.enabled = true;
    _editor.text = value;
  }

  EditorInterface get _editor => shadowRoot.query('editor-element').xtag;

}
