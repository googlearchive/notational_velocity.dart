// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library observe.test.observe_test_utils;

import 'package:unittest/unittest.dart';
import 'dart:async' show Completer, runZonedExperimental;
import 'dart:collection';
import 'package:observe/observe.dart' show Observable;

// TODO(jmesserly): use matchers when we have a way to compare ChangeRecords.
// For now just use the toString.
expectChanges(actual, expected, {reason}) =>
    expect('$actual', '$expected', reason: reason);

/**
 * This is a special kind of unit [test], that supports
 * calling [performMicrotaskCheckpoint] during the test to pump events
 * that original from observable objects.
 */
observeTest(name, testCase) => test(name, wrapMicrotask(testCase));

/** The [solo_test] version of [observeTest]. */
solo_observeTest(name, testCase) => solo_test(name, wrapMicrotask(testCase));

// TODO(jmesserly): remove "microtask" from these names and instead import
// the library "as microtask"?

/**
 * This change pumps events relevant to observers and data-binding tests.
 * This must be used inside an [observeTest].
 *
 * Executes all pending [runAsync] calls on the event loop, as well as
 * performing [Observable.dirtyCheck], until there are no more pending events.
 * It will always dirty check at least once.
 */
// TODO(jmesserly): do we want to support nested microtasks similar to nested
// zones? Instead of a single pending list we'd need one per wrapMicrotask,
// and [performMicrotaskCheckpoint] would only run pending callbacks
// corresponding to the innermost wrapMicrotask body.
void performMicrotaskCheckpoint() {
  Observable.dirtyCheck();

  while (_pending.isNotEmpty) {
    print('looping thru pending');

    for (int len = _pending.length; len > 0 && _pending.isNotEmpty; len--) {
      print("-executing a callback");
      final callback = _pending.removeFirst();
      try {
        callback();
      } catch (e, s) {
        new Completer().completeError(e, s);
      }
    }

    Observable.dirtyCheck();
  }
}

final Queue<Function> _pending = new Queue<Function>();

/**
 * Wraps the [body] in a zone that supports [performMicrotaskCheckpoint],
 * and returns the body.
 */
// TODO(jmesserly): deprecate? this doesn't add much over runMicrotask.
wrapMicrotask(body()) => () => runMicrotask(body);

/**
 * Runs the [body] in a zone that supports [performMicrotaskCheckpoint],
 * and returns the result.
 */
runMicrotask(body()) => runZonedExperimental(() {
  try {
    return body();
  } finally {
    performMicrotaskCheckpoint();
  }
}, onRunAsync: _onRunAsync);

void _onRunAsync(callback) {
  print("adding a callback...");
  _printStack();
  _pending.add(callback);
}

void _printStack() {
  try {
    throw new UnimplementedError('yay!');
  } catch (e, s) {
    print(s);
  }
}