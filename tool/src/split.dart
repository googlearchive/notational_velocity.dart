library nv.tool.split;

import 'dart:convert';

class Section {
  final String header;
  final String content;

  Section(this.header, this.content);
}

class SectionSplitter extends Converter<String, List<Section>> {
  List<Section> convert(String data) {
    var lines = new List<Section>();

    _SectionSplitterSink._addSlice(data, 0, data.length, true, lines.add);

    return lines;
  }

  ChunkedConversionSink startChunkedConversion(ChunkedConversionSink<Section> sink) {
    return new _SectionSplitterSink(sink);
  }
}

class _SectionSplitterSink extends StringConversionSinkBase {
  static const int _LF = 10;
  static const int _CR = 13;

  final ChunkedConversionSink<Section> _sink;

  String _carry;

  _SectionSplitterSink(this._sink);

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

  static String _addSlice(String chunk, int start, int end, bool isLast, void adder(Section record)) {
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
        var val = chunk.substring(startPos, pos);

        adder(new Section(null, val));
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
      adder(new Section(null, carry));
      return null;
    }
    return carry;
  }
}

