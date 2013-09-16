library observe.test.observe_test_utils;

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
