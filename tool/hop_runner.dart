library nv.hop;

import 'dart:async';
import 'package:hop/hop.dart';
import 'package:hop/hop_tasks.dart';

import '../test/harness_console.dart' as test_console;
import 'src/chrome.dart' as chrome;
import 'src/polymer_build.dart' as build;

void main() {

  addTask('test', createUnitTestTask(test_console.testCore));

  addTask('chrome', new Task.async(_launchChrome));

  //
  // app_dart2js
  //
  final chromeTestHarnessPaths = ['test/app/harness_packaged.dart'];

  addTask('app_dart2js', createDartCompilerTask(chromeTestHarnessPaths,
      liveTypeAnalysis: true));

  addTask('update_js', createCopyJSTask('test/app',
      unittestTestController: true,
      browserDart: true,
      browserInterop: true,
      jsDartInterop: true));

  addTask('build', new Task.async((ctx) => build.build('web/index.html', 'build')));

  addTask('dart2js', createDartCompilerTask(['build/web/index.html_bootstrap.dart'],
      minify: true,
      liveTypeAnalysis: true));

  addChainedTask('package_test_compile_and_run', ['app_dart2js', 'chrome']);

  runHop();
}

Future<bool> _launchChrome(TaskContext ctx) {
  return chrome.launchChrome('test').then((int exitCode) => exitCode == 0);
}
