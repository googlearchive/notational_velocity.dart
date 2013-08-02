library nv.tool.chrome;

import 'dart:async';
import 'dart:io';
import 'package:bot_io/bot_io.dart';

// TODO: use an environment variable for this?
const _chromePath = '/Users/kevin/source/dev/Google Chrome.app/Contents/MacOS/Google Chrome';

Future launchChrome() {
  var testLaunch =
    {
     'load-and-launch-app': '/Users/kevin/source/github/pop-pop-win/app_package',
     'no-startup-window': null
    };

  return TempDir.then((dir) => _launchChrome(dir, testLaunch));
}

Future _launchChrome(Directory tempDir, [Map<String, String> argsMap]) {

  if(argsMap == null) {
    argsMap = {};
  }
  argsMap['user-data-dir'] = tempDir.path;
  argsMap['no-default-browser-check'] = null;
  argsMap['no-first-run'] = null;

  var args = argsMap.keys.map((key) {
    var value = argsMap[key];

    var str = "--$key";
    if(value == null) {
      return str;
    } else {
      return "$str=$value";
    }
  }).toList(growable: false);

  print(args);

  return Process.run(_chromePath, args)
      .then((ProcessResult pr) {

        if(pr.exitCode != 0) {
          print(pr.stdout);
          print(pr.stderr);
          throw new Exception('chrome did not exit happy');
        }
      });
}
