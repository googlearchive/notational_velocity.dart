library test.nv.tool.chrome;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:unittest/unittest.dart';
import '../../tool/src/split.dart';

void main() {
  group('chrome', () {
    test('log parsing', _test);
  });
}

Future _test() {
  var file = new File('test/data/chrome_log.txt');
  assert(file.existsSync());

  return file.openRead()
      .transform(new Utf8Decoder())
      .transform(new SectionSplitter())
      .forEach((Section block) {
        //print('Line!');
        //print(block);
      });
}

//final _chromeLogRegexp = new RegExp('\[(\d+)\:(\d+)\:(\d+)/(\d+):(\w+):(.*)\]', multiLine: false);
