part of nv.controllers;

class NoteListViewModel {
  final ObservableList<Note> notes;
  final CollectionView<Note> _cv;
  final SelectionManager<Note> view;

  factory NoteListViewModel(ObservableList<Note> notes) {

    var cv = new CollectionView(notes);
    var sm = new SelectionManager<Note>(cv);
    return new NoteListViewModel._(notes, cv, sm);
  }

  NoteListViewModel._(this.notes, this._cv, this.view);
}
