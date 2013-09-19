library test.nv.note_list;

import 'dart:async';
import 'package:unittest/unittest.dart';

import 'package:nv/src/controllers.dart';
import 'package:nv/src/models.dart';
import 'package:nv/src/serialization.dart';
import 'package:nv/src/storage.dart';
import 'package:nv/src/shared.dart';

void main(Storage storageFactory()) {
  group('NoteList', () {
    _testNoteList('simple', storageFactory, (store, list) {
      expect(list, isEmpty);

      var nvm = list.create('Test Title');
      expect(nvm.title, 'Test Title');
      expect(nvm.lastModified.compareTo(currentTestCase.startTime),
          greaterThanOrEqualTo(0));

      return nvm.whenUpdated
          .then((_) {

            return store.getKeys();
          })
          .then((List<String> keys) {
            expect(keys, hasLength(1));
            expect(keys.first, nvm.id.toString());
          });
    });

    _testNoteList('existing', storageFactory, (store, list) {

    }, existingCount: 5);
  });
}

void _testNoteList(String name, Storage storageFactory(),
                   Future testFunc(Storage store, NoteList list),
                   {int existingCount: 0}) {
  test(name, () {
    var store = storageFactory();
    return _populateNotes(store, existingCount)
        .then((_) => NoteList.init(store))
        .then((NoteList list) => testFunc(store, list));
  });
}

Future _populateNotes(Storage store, int count) {
  var items = new List.generate(count, (i) => i, growable: false);

  return Future.forEach(items, (i) => _populateNote(store, i))
      .then((_) => store.getKeys())
      .then((List<String> keys) {
        expect(keys, hasLength(count));
      });
}

Future _populateNote(Storage store, int id) {
  assert(id >= 0);

  // don't support more yet...
  assert(id < 256);
  var idBytes = new List.filled(16, 0);
  idBytes[15] = id;

  var uuid = new KUID(idBytes);

  var note = new Note('Title $id', new DateTime.now(), 'Content $id');

  return store.set(uuid.toString(), NOTE_CODEC.encode(note));
}
