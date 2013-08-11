library test.nv.app_model;

import 'dart:async';
import 'package:unittest/unittest.dart';

import 'package:nv/src/controllers.dart';
import 'package:nv/src/models.dart';
import 'package:nv/src/storage.dart';

const _testTitle1 = 'Test Title 1';

void main(Storage storage) {
  setUp(() {
    return storage.clear();
  });

  group('AppModel', () {

    test('simple', () {
      var appModel = new AppController(storage);

      return _testSimple(appModel);
    });

  });
}

Future _testSimple(AppController model) {
  _expectClean(model);

  final tc = new TextContent('first content!');

  return model.openOrCreateNote(_testTitle1)
      .then((Note note) {
        expect(note, isNotNull);

        var nc = note.content;
        expect(nc is TextContent, isTrue);
        expect(nc.value, isEmpty);

        return model.updateNote(_testTitle1, tc);
      })
      .then((_) {
        var titleVariations = _permutateTitle(_testTitle1)
            ..add('Test');

        return Future.forEach(titleVariations, (t) {
          return model.openOrCreateNote(_testTitle1)
            .then((Note nc) {
              expect(nc.content, tc);
      });
        });
      });
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
