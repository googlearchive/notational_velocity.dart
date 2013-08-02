library nv.tool.chrome;

import 'dart:async';
import 'dart:io';
import 'package:bot_io/bot_io.dart';

// TODO: use an environment variable for this?
const _chromePath = '/Users/kevin/source/dev/Google Chrome.app/Contents/MacOS/Google Chrome';

Future launchChrome() {
  return TempDir.then(_launchChrome);
}

Future _launchChrome(Directory tempDir) {
  print('rockin $tempDir');

  var argsMap = {};
  argsMap['user-data-dir'] = tempDir.path;

  var args = argsMap.keys.map((key) {
    var value = argsMap[key];
    return "--$key=$value";
  }).toList(growable: false);

  return Process.run(_chromePath, args)
      .then((ProcessResult pr) {
        print(pr.stdout);
        print(pr.stderr);
        print(pr.exitCode);
      });
}
