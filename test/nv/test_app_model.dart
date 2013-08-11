library test.nv.app_model;

import 'dart:async';
import 'package:unittest/unittest.dart';

import 'package:nv/src/controllers.dart';
import 'package:nv/src/models.dart';

const _testTitle1 = 'Test Title 1';

void main() {
  group('AppModel', () {

    test('simple', () {
      var appModel = new AppController(new Map<String, Note>());

      _testSimple(appModel);
    });

  });
}

void _testSimple(AppController model) {
  _expectClean(model);

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
}

List<String> _permutateTitle(String title) {
  expect(title, title);
  expect(title.toLowerCase(), isNot(title));
  expect(title.toUpperCase(), isNot(title));
  expect(title.toUpperCase(), isNot(title.toLowerCase()));

  return [title, title.toLowerCase(), title.toUpperCase()];
}

Future _expectClean(AppController appModel) {
  //expect(appModel.working, isFalse);
  expect(appModel.notes, isEmpty);
}
