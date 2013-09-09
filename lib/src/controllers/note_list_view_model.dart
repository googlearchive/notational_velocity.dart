part of nv.controllers;

class NoteListViewModel {
  final ObservableList<Note> notes;
  final CollectionView<Note> _cv;
  final MappedListView<Note, NoteController> view;

  factory NoteListViewModel(ObservableList<Note> notes, Mapper<Note, NoteController> mapper) {

    var cv = new CollectionView(notes);
    var mlv = new MappedListView<Note, NoteController>(cv, mapper);
    return new NoteListViewModel._(notes, cv, mlv);
  }

  NoteListViewModel._(this.notes, this._cv, this.view);
}
