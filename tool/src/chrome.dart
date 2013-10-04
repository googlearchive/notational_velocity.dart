library nv.tool.chrome;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bot_io/bot_io.dart';
import 'package:nv/src/shared.dart';

const _CHROME_PATH_ENV_KEY = 'CHROME_PATH';
const _MAC_CHROME_PATH = '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';

Future<int> launchChrome(String manifestDir, {String chromePath,
  bool logStdOut: false, bool logStdErr: true, bool logVerbose: true,
  int debugPort: null}) {

  if(chromePath == null) {
    chromePath = Platform.environment[_CHROME_PATH_ENV_KEY];
  }
  if(chromePath == null && Platform.isMacOS) {
    chromePath = _MAC_CHROME_PATH;
  }

  if(chromePath == null) {
    throw new ArgumentError('"chromePath" must be provided or the '
        '$_CHROME_PATH_ENV_KEY environment variable must be set');
  }

  if(!FileSystemEntity.isFileSync(chromePath)) {
    throw new Exception('Could not find Chrome at $chromePath');
  }

  // see http://peter.sh/experiments/chromium-command-line-switches/
  var config =
    {
     'debug-packed-apps': null,
     'disable-background-networking': null, // stop random updates clogging log
     'disable-default-apps': null, // don't need gmail, drive, etc
     'enable-logging': 'stderr',
     'load-and-launch-app': manifestDir,
     'no-default-browser-check': null,
     'no-first-run': null,
     'no-startup-window': null
    };

  if(logVerbose) {
    config['v'] = null;
  }

  if(debugPort != null) {
    config['remote-debugging-port'] = debugPort;
  }

  return TempDir
      .then((dir) {
        config['user-data-dir'] = dir.path;
        return _launchChrome(chromePath, config, logStdOut, logStdErr);
      });
}

Future<int> _launchChrome(String chromePath,
    Map<String, String> argsMap, bool logStdOut, bool logStdErr) {

  var args = argsMap.keys.map((key) {
    assert(!key.startsWith('-'));
    var value = argsMap[key];

    var str = "--$key";
    if(value == null) {
      return str;
    } else {
      return "$str=$value";
    }
  }).toList(growable: false);

  return Process.start(chromePath, args)
      .then((Process process) {

        _captureStd(logStdOut, process.stdout);
        _captureStd(logStdErr, process.stderr);

        return process.exitCode;
      });
}

void _captureStd(bool process, Stream<List<int>> std) {

  std.transform(UTF8.decoder)
    .transform(new SectionSplitter(chromeLogRegexp))
    .map(ChromeLogEntry.parse)
    .listen((ChromeLogEntry value) {
      if(process) {
        print([value.kind, value.details, value.content]);
        if(value.kind == 'INFO' && value.details.startsWith('CONSOLE(')) {
          _print(value.content, AnsiColor.GREEN);
        }
      }
    });
}

void _print(String value, [AnsiColor color]) {
  if(color != null) {
    var ss = new ShellString.withColor(value, color);
    value = ss.format(true);
  }
  print(value);
}

class ChromeLogEntry {
  final String pid;
  final String other;
  final String monthDay;
  final String hourMinSec;
  final String kind;
  final String details;
  final String content;

  ChromeLogEntry(this.pid, this.other, this.monthDay, this.hourMinSec, this.kind, this.details, this.content);

  static ChromeLogEntry parse(Section input) {
    var match = chromeLogRegexp.allMatches(input.header).single;

    assert(match.groupCount == 6);

    return new ChromeLogEntry(match[1], match[2], match[3], match[4], match[5], match[6], input.content.trim());
  }

}



final chromeLogRegexp = new RegExp(r'^\[(\d+):(\d+):(\d+)/(\d+):(\w+):([^\]]+)\] ', multiLine: true);
