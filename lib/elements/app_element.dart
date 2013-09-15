import 'dart:html';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:polymer/polymer.dart';
import 'package:nv/init.dart' as init;
import 'package:nv/elements/interfaces.dart';
import 'package:nv/src/controllers.dart';
import 'package:nv/src/shared.dart';

final _libLogger = new Logger('nv.AppElement');

@CustomTag('app-element')
class AppElement extends PolymerElement with ChangeNotifierMixin {
  bool get applyAuthorStyles => true;

  bool _childEventsWired = false;
  AppController _controller;

  AppController get controller => _controller;

  AppElement() {
    init.controllerFuture.then((AppController value) {
      assert(_controller == null);
      _controller = value;

      _controller.onSearchReset.listen(_controller_onSearchReset);

      filterPropertyChangeRecords(_controller.notes, const Symbol('selectedValue'))
        .listen(_selectedNoteChanged);

      notifyChange(new PropertyChangeRecord(const Symbol('controller')));
    });
  }

  //
  // Overrides
  //

  @override
  void inserted() {
    assert(!_childEventsWired);

    // TODO: hold on to the subscriptions. Tear down at some point?
    filterPropertyChangeRecords(_editor, const Symbol('text'))
      .listen(_editorTextChanged);

    _childEventsWired = true;
  }

  //
  // Implementation
  //

  void _controller_onSearchReset(_) {
    var searchInput = shadowRoot.query('#search_input');
    searchInput.focus();
  }

  void _editorTextChanged(PropertyChangeRecord record) {
    // only save the current note if the editor is enabled
    if(_editor.enabled) {
      _controller.updateSelectedNoteContent(_editor.text);
    }
  }

  void _selectedNoteChanged(PropertyChangeRecord record) {
    _libLogger.info('_selectedNoteChanged');

    var notes = _controller.notes;

    if(notes.hasSelection) {

      var value = notes.selectedValue.content;

      _editor.enabled = true;
      _editor.text = value;
    } else {
      _editor.enabled = false;
      // disabling editor should clear the next value
      assert(_editor.text == '');
    }
  }

  EditorInterface get _editor => shadowRoot.query('editor-element').xtag;

}
