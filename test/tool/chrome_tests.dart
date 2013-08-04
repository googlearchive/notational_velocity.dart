library test.nv.tool.chrome;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:unittest/unittest.dart';

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
      .transform(new LineSplitter())
      .forEach((String block) {
        print('Line!');
        print(block.length);
      });
}

//final _chromeLogRegexp = new RegExp('\[(\d+)\:(\d+)\:(\d+)/(\d+):(\w+):(.*)\]', multiLine: false);


class LineSplitter extends Converter<String, List<String>> {
  List<String> convert(String data) {
    var lines = new List<String>();

    _LineSplitterSink._addSlice(data, 0, data.length, true, lines.add);

    return lines;
  }

  ChunkedConversionSink startChunkedConversion(ChunkedConversionSink<String> sink) {
    if (sink is! StringConversionSink) {
      sink = new StringConversionSink.from(sink);
    }
    return new _LineSplitterSink(sink);
  }
}

class _LineSplitterSink extends StringConversionSinkBase {
  static const int _LF = 10;
  static const int _CR = 13;

  final StringConversionSink _sink;

  String _carry;

  _LineSplitterSink(this._sink);

  void addSlice(String chunk, int start, int end, bool isLast) {
    if(_carry != null) {
      chunk = _carry + chunk.substring(start, end);
      start = 0;
      end = chunk.length;
      _carry = null;
    }
    _carry = _addSlice(chunk, start, end, isLast, _sink.add);
    if(isLast) _sink.close();
  }

  void close() {
    addSlice('', 0, 0, true);
  }

  static String _addSlice(String chunk, int start, int end, bool isLast, void adder(String)) {
    String carry = null;
    int startPos = start;
    int pos = start;
    while (pos < end) {
      int skip = 0;
      int char = chunk.codeUnitAt(pos);
      if (char == _LF) {
        skip = 1;
      } else if (char == _CR) {
        skip = 1;
        if (pos + 1 < end) {
          if (chunk.codeUnitAt(pos + 1) == _LF) {
            skip = 2;
          }
        } else if (!isLast) {
          return chunk.substring(startPos, end);
        }
      }
      if (skip > 0) {
        adder(chunk.substring(startPos, pos));
        startPos = pos = pos + skip;
      } else {
        pos++;
      }
    }
    if (pos != startPos) {
      // Add remaining
      carry = chunk.substring(startPos, pos);
    }
    if(isLast && carry != null) {
      adder(carry);
      return null;
    }
    return carry;
  }
}
