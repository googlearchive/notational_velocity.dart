part of nv.controllers;

class NoteController extends ChangeNotifierBase implements Note {
  final Note note;
  final AppController _app;

  bool _isSelected = false;

  NoteController(this.note, this._app) {
    assert(note != null);
    assert(_app != null);
    _isSelected = (_app.selectedNote == note);
  }

  String get title => note.title;

  String get key => note.key;

  NoteContent get content => note.content;

  DateTime get lastModified => note.lastModified;

  bool get isSelected => _isSelected;

  void requestSelect() {
    _app._requestSelect(this);
  }

  void _updateIsSelected(bool value) {
    if(value != _isSelected) {
      _isSelected = value;
      _notifyChange(const Symbol('isSelected'));
    }
  }

  void _notifyChange(Symbol prop) {
    notifyChange(new PropertyChangeRecord(prop));
  }
}
