library test.nv.note_list;

import 'dart:async';
import 'package:unittest/unittest.dart';

import 'package:nv/src/controllers.dart';
import 'package:nv/src/storage.dart';

void main(Storage storageFactory()) {
  group('NoteList', () {
    _testNoteList('simple', storageFactory, (store, list) {

      expect(list, isEmpty);

    });
  });
}

void _testNoteList(String name, Storage storageFactory(),
                   Future testFunc(Storage store, NoteList list)) {
  test(name, () {
    var store = storageFactory();
    return NoteList.init(store)
        .then((NoteList list) {
          return testFunc(store, list);
        });
  });
}
