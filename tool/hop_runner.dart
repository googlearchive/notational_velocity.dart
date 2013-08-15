library nv.hop;

import 'dart:async';
import 'dart:io';
import 'package:hop/hop.dart';
import 'package:hop/hop_tasks.dart';
import 'package:hop/src/hop_experimental.dart' as hop_ex;

import '../test/harness_console.dart' as test_console;
import 'src/chrome.dart' as chrome;
import 'src/polymer_build.dart' as build;

void main() {

  addTask('test', createUnitTestTask(test_console.testCore));

  addTask('chrome', new Task.async(_launchChrome));

  //
  // app_dart2js
  //
  final paths = ['test/app/harness_packaged.dart'];

  addTask('app_dart2js', createDartCompilerTask(paths,
      liveTypeAnalysis: true,
      allowUnsafeEval: false));

  var map = {
             'packages/unittest/test_controller.js': 'test/app/test_controller.js',
             'packages/browser/dart.js': 'test/app/dart.js',
             'packages/browser/interop.js': 'test/app/interop.js',
             'packages/js/dart_interop.js': 'test/app/dart_interop.js',
    };

  addTask('update_js', new Task.async((TaskContext ctx) => _copyFiles(ctx, map)));

  addTask('build', new Task.async((ctx) => build.build([], ['web/index.html'])));

  runHop();
}

Future<bool> _launchChrome(TaskContext ctx) {
  return chrome.launchChrome('test').then((int exitCode) => exitCode == 0);
}

Future<bool> _copyFiles(TaskContext ctx, Map<String, String> sourceToDest) {
  return Future.forEach(sourceToDest.keys, (String sourcePath) {
    var destPath = sourceToDest[sourcePath];

    ctx.config('Checking $destPath with $sourcePath');

    return _copyFile(sourcePath, destPath)
        .then((bool success) {
          if(success) {
            ctx.info('$destPath updated with content from $sourcePath');
          } else {
            ctx.info('$destPath is the same as $sourcePath');
          }
        });
  }).then((_) => true);
}

Future<bool> _copyFile(String sourcePath, String destinationPath) {

  return hop_ex.transformFile(destinationPath, (String original) {
    var source = new File(sourcePath);
    return source.readAsString();
  });
}
