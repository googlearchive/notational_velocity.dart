library nv.hop;

import 'dart:async';
import 'package:hop/hop.dart';
import 'package:hop/hop_tasks.dart';

import '../test/harness_console.dart' as test_console;
import 'src/chrome.dart' as chrome;

void main() {

  addTask('test', createUnitTestTask(test_console.testCore));

  addTask('chrome', new Task.async(_launchChrome));

  runHop();
}

Future<bool> _launchChrome(TaskContext ctx) {
  return chrome.launchChrome().then((_) => true);
}
