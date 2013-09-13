// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library observe.test.observe_test_utils;

import 'package:unittest/unittest.dart';

void expectChanges(Iterable actual, Iterable expected, {String reason}) {
  if(actual == null && expected == null) return;

  var actualStrings = actual.map((e) => e.toString()).toList();
  var expectedStrings = expected.map((e) => e.toString()).toList();

  expect(actualStrings, orderedEquals(expectedStrings), reason: reason);
}
