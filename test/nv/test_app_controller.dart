library test.nv.app_controller;

import 'dart:async';
import 'package:unittest/unittest.dart';
import 'package:observe/observe.dart';

import 'package:nv/src/config.dart';
import 'package:nv/src/controllers.dart';
import 'package:nv/src/models.dart';
import 'package:nv/src/shared.dart';

import 'package:nv/src/serialization.dart';
import 'package:nv/src/storage.dart';
import 'package:nv/src/sync.dart';

const _testTitle1 = 'Test Title 1';

void main(Storage storage) {
  group('AppController', () {

    _testAppController('simple', storage, _testSimple);

  });
}

Future _testSimple(AppController model) {
  _expectFirstRun(model);

  final tc = new TextContent('first content!');

  model.searchTerm = _testTitle1;

  var note = model.openOrCreate();
  expect(note, isNotNull);

  var nc = note.content;
  expect(nc is TextContent, isTrue);
  expect(nc.value, isEmpty);

  model.updateSelectedNoteContent(tc.value);

  var titleVariations = _permutateTitle(_testTitle1)
    ..add('Test');

  /*

  TODO: need to futz w/ search logic here
  for(var t in titleVariations) {
    model.searchTerm = t;
    var nc = model.openOrCreate();
    expect(nc.title, _testTitle1);
    expect(nc.content, tc);
  }*/

  expect(model.isUpdated, isFalse);

  return _whenUpdated(model);
}

List<String> _permutateTitle(String title) {
  expect(title, title);
  expect(title.toLowerCase(), isNot(title));
  expect(title.toUpperCase(), isNot(title));
  expect(title.toUpperCase(), isNot(title.toLowerCase()));

  return [title, title.toLowerCase(), title.toUpperCase()];
}

Future<AppController> _whenUpdated(AppController controller) {
  if(controller.isUpdated) {
    return new Future.sync(() => null);
  }

  return filterPropertyChangeRecords(controller, const Symbol('isUpdated'))
      .where((PropertyChangeRecord pcr) {
        return controller.isUpdated;
      })
      .first
      .then((PropertyChangeRecord pcr) {
        assert(pcr.field == const Symbol('isUpdated'));
        return controller;
      });
}

Future _expectFirstRun(AppController controller) {
  expect(controller.notes, hasLength(INITIAL_NOTES.length));

  for(var note in controller.notes) {
    var match = INITIAL_NOTES[note.title];
    expect(match, isNotNull);
    expect(note.content is TextContent, isTrue);

    TextContent tc = note.content;
    expect(tc.value, match);
  }
}

Future<AppController> _getDebugController(Storage storage) {
  return MapSync.createAndLoad(storage, NOTE_CODEC)
    .then((MapSync<Note> ms) => new AppController(ms))
    .then(_whenUpdated);
}

void _testAppController(String name, Storage storage, testFunc(AppController ac)) {
  test(name, () {
    return _getDebugController(storage).then(testFunc);
  });
}

