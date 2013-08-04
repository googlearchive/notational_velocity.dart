library test.nv.tool.chrome;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:unittest/unittest.dart';
import '../../tool/src/split.dart';

void main() {
  group('split', () {
    test('test parsing', _test);
  });
}

Future _test() {
  var file = new File('test/data/pride_and_prejudice.txt');
  assert(file.existsSync());

  return file.openRead()
      .transform(new Utf8Decoder())
      .transform(new SectionSplitter())
      .take(2)
      .toList()
      .then((List<Section> sections) {
        expect(sections, hasLength(2));
      });
}

//final _chromeLogRegexp = new RegExp('\[(\d+)\:(\d+)\:(\d+)/(\d+):(\w+):(.*)\]', multiLine: false);

final _pAndPFirst = '''The Project Gutenberg EBook of Pride and Prejudice, by Jane Austen

This eBook is for the use of anyone anywhere at no cost and with
almost no restrictions whatsoever.  You may copy it, give it away or
re-use it under the terms of the Project Gutenberg License included
with this eBook or online at www.gutenberg.org


Title: Pride and Prejudice

Author: Jane Austen

Posting Date: August 26, 2008 [EBook #1342]
Release Date: June, 1998
[Last updated: October 12, 2012]

Language: English


*** START OF THIS PROJECT GUTENBERG EBOOK PRIDE AND PREJUDICE ***




Produced by Anonymous Volunteers





PRIDE AND PREJUDICE

By Jane Austen



''';