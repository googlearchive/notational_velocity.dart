library test.nv.app_controller;

import 'dart:async';
import 'package:unittest/unittest.dart';

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

    test('simple', () {
      return _getDebugController(storage)
          .then((AppController ac) => _testSimple(ac));
    });

  });
}

Future<AppController> _getDebugController(Storage storage) {
  return MapSync.createAndLoad(storage, NOTE_CODEC)
    .then((MapSync<Note> ms) => new AppController(ms));
}

Future _testSimple(AppController model) {
  _expectFirstRun(model);

  final tc = new TextContent('first content!');

  var note = model.openOrCreateNote(_testTitle1);
  expect(note, isNotNull);

  var nc = note.content;
  expect(nc is TextContent, isTrue);
  expect(nc.value, isEmpty);

  model.updateNote(_testTitle1, tc);

  var titleVariations = _permutateTitle(_testTitle1)
    ..add('Test');

  for(var t in titleVariations) {
    var nc = model.openOrCreateNote(_testTitle1);
    expect(nc.title, _testTitle1);
    expect(nc.content, tc);
  }

  expect(model.isUpdated, isFalse);

  return firstPropChangeRecord(model, const Symbol('isUpdated'));
}

List<String> _permutateTitle(String title) {
  expect(title, title);
  expect(title.toLowerCase(), isNot(title));
  expect(title.toUpperCase(), isNot(title));
  expect(title.toUpperCase(), isNot(title.toLowerCase()));

  return [title, title.toLowerCase(), title.toUpperCase()];
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