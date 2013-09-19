library observe.test.observe_test_utils;

import 'package:bot/bot.dart';
import 'package:observe/observe.dart';
import 'package:unittest/unittest.dart';

void expectChanges(Iterable actual, Iterable expected, {String reason}) {
  if(actual == null && expected == null) return;
  if(actual == null) {
    actual = [];
  } else if(expected == null) {
    expected = [];
  }

  var actualStrings = actual.map((e) => e.toString()).toList();
  var expectedStrings = expected.map((e) => e.toString()).toList();

  expect(actualStrings, orderedEquals(expectedStrings), reason: reason);
}

const LENGTH = const Symbol('length');

final lengthChange = new PropertyChangeRecord(LENGTH);

ListChangeRecord change(index, {removedCount: 0, addedCount: 0}) =>
    new ListChangeRecord(index, removedCount: removedCount,
        addedCount: addedCount);

const isDisposedError =
    const _DisposedError();

const Matcher throwsADisposedError =
    const Throws(isDisposedError);

class _DisposedError extends TypeMatcher {
  const _DisposedError() : super("DisposedError");

  bool matches(item, Map matchState) {
    print('Wondering if this is a DisposedError');
    var isExpectedError = item is DisposedError;
    print([item, item.runtimeType, isExpectedError]);
    return isExpectedError;
  }
}
