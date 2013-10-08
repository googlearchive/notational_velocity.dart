library nv.hop;

import 'dart:async';
import 'dart:io';
import 'package:hop/hop.dart';
import 'package:hop/hop_tasks.dart';

import '../test/harness_console.dart' as test_console;
import 'src/chrome.dart' as chrome;
import 'src/copy_dir.dart' as cd;
import 'src/polymer_build.dart' as build;
import 'src/make_page.dart' as page;

void main() {

  addTask('test', createUnitTestTask(test_console.testCore));

  addTask('chrome', new Task.async(_launchChrome));

  addTask('run-app', new Task.async(_runApp));

  //
  // app_dart2js
  //
  final chromeTestHarnessPaths = ['test/chrome/harness_packaged.dart'];

  addTask('app_dart2js', createDartCompilerTask(chromeTestHarnessPaths,
      liveTypeAnalysis: true));

  addTask('update_js', createCopyJSTask('test/chrome',
      unittestTestController: true,
      browserDart: true,
      browserInterop: true));

  addTask('build', new Task.async(_buildApp));

  addTask('dart2js', createDartCompilerTask(['build/web/index.html_bootstrap.dart'],
      minify: true,
      liveTypeAnalysis: true));

  addChainedTask('build_and_compile', ['build', 'dart2js']);

  //
  // gh_pages
  //
  addTask('pages', page.makePageCrazy());

  addChainedTask('package_test_compile_and_run', ['app_dart2js', 'chrome']);

  runHop();
}

Future<bool> _buildApp(TaskContext ctx) {
  return build.build('web/index.html', 'build')
      .then((bool success) {
        if(!success) {
          return false;
        }

        Process.runSync('rm', ['-rf', 'build/packages/']);
        Process.runSync('rm', ['-rf', 'build/web/packages']);

        var dest = 'build/web/packages/';

        if(FileSystemEntity.typeSync(dest) != FileSystemEntityType.NOT_FOUND) {
          var destDir = new Directory(dest);
          destDir.deleteSync(recursive: true);
        }

        cd.copyDirectory('packages/', dest);

        return true;
      });

}

Future<bool> _launchChrome(TaskContext ctx) {
  return chrome.launchChrome('test').then((int exitCode) => exitCode == 0);
}

Future<bool> _runApp(TaskContext ctx) {
  return chrome.launchChrome('build/web').then((int exitCode) => exitCode == 0);
}
