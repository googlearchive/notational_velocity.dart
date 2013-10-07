library nv.elements.app;

import 'dart:html';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:polymer/polymer.dart';

import 'package:nv/init.dart' as init;
import 'package:nv/elements/interfaces.dart';
import 'package:nv/src/controllers.dart';
import 'package:nv/src/models.dart';
import 'package:nv/src/shared.dart';

final _libLogger = new Logger('nv.AppElement');

void _log(String msg) {
  _libLogger.info(msg);
}

@CustomTag('app-element')
class AppElement extends PolymerElement with ChangeNotifierMixin {
  bool get applyAuthorStyles => true;

  bool _childEventsWired = false;
  AppController _controller;

  Note _searchFieldOpenItem;

  AppController get controller => _controller;

  AppElement() {
    init.controllerFuture.then((AppController value) {
      assert(_controller == null);
      _controller = value;

      _controller.onSearchReset.listen(_controller_onSearchReset);

      filterPropertyChangeRecords(_controller.notes, const Symbol('selectedValue'))
        .listen(_selectedNoteMutated);

      filterPropertyChangeRecords(_editor, const Symbol('enabled'))
        .listen(_editor_enabledMutated);

      _configureWindowEventHandlers();

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
      .listen(_editorTextMutated);

    _childEventsWired = true;

    InputElement searchInput = shadowRoot.query('#search_input');
    searchInput.focus();
  }

  //
  // Event Handlers
  //

  void searchKeyUp(KeyboardEvent e, dynamic detail, Node target) {
    if(e.keyCode == KeyCode.ENTER) {
      _openSearchText();
    }
  }

  void _editor_enabledMutated(PropertyChangeRecord pcr) {
    if(_editor.enabled &&
        _controller.notes.selectedValue == _searchFieldOpenItem) {
      assert(_searchFieldOpenItem != null);
      _editor.focusText();
    }
    _searchFieldOpenItem = null;
  }

  //
  // Implementation
  //

  void _openSearchText() {
    _log('_openSearchText - ${controller.searchTerm}');
    // TODO: ponder a locking model to prevent weirdness while waiting for
    // async methods called no controller?
    controller.openOrCreate()
      .then((Note item) {
        if(_controller.notes.selectedValue == item && _editor.enabled) {
          _editor.focusText();
          _searchFieldOpenItem = null;
        } else {
          _searchFieldOpenItem = item;
        }
      });
  }

  void _controller_onSearchReset(_) {
    var searchInput = shadowRoot.query('#search_input');
    searchInput.focus();
  }

  void _editorTextMutated(PropertyChangeRecord record) {
    // only save the current note if the editor is enabled
    if(_editor.enabled) {
      _controller.updateSelectedNoteContent(_editor.text);
    }
  }

  void _selectedNoteMutated(PropertyChangeRecord record) {
    _log('_selectedNoteChanged - ${_controller.notes.selectedValue}');

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

  UnknownElement get _editorCore => shadowRoot.query('editor-element');

  EditorInterface get _editor => _editorCore.xtag;

  void _configureWindowEventHandlers() {
    window.onKeyDown.listen(_window_keyDown);
  }

  void _window_keyDown(KeyboardEvent e) {
    switch(e.keyCode) {
      case KeyCode.ESC:
        e.preventDefault();
        _controller.resetSearch();
        break;
      case KeyCode.DOWN:
      case KeyCode.UP:
        if(shadowRoot.activeElement != _editorCore) {
          e.preventDefault();

          if(e.keyCode == KeyCode.DOWN) {
            _controller.moveSelectionDown();
          } else {
            assert(e.keyCode == KeyCode.UP);
            _controller.moveSelectionUp();
          }
        }
        break;
    }
  }

}
