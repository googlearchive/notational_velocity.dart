library test.nv.app_model;

import 'dart:async';
import 'package:unittest/unittest.dart';
import 'package:nv/src/models.dart';
import 'package:nv/src/storage.dart';

const _testTitle1 = 'Test Title 1';

void main(Storage storage) {
  setUp(() {
    return storage.clear();
  });

  group('AppModel', () {

    test('test title varies enough', () {
      expect(_testTitle1.toLowerCase(), isNot(_testTitle1));
      expect(_testTitle1.toUpperCase(), isNot(_testTitle1));
      expect(_testTitle1, _testTitle1);
    });

    test('simple', () {
      var appModel = new AppModel(storage);

      return _testSimple(appModel);
    });

  });
}

Future _testSimple(AppModel model) {
  _expectClean(model);

  final tc = new TextContent('first content!');

  return model.openOrCreateNote(_testTitle1)
      .then((NoteContent nc) {
        expect(nc, isNotNull);
        expect(nc is TextContent, isTrue);
        expect(nc.value, isEmpty);

        return model.updateNote(_testTitle1, tc);
      })
      .then((_) {
        return model.openOrCreateNote(_testTitle1);
      })
      .then((NoteContent nc) {
        expect(nc, tc);
      });
}

Future _expectClean(AppModel appModel) {
  //expect(appModel.working, isFalse);
  expect(appModel.notes, isEmpty);
}
