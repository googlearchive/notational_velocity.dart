library nv.tool.split;

import 'dart:convert';
import 'package:bot/bot.dart';

class Section {
  final String header;
  final String content;

  Section(this.header, this.content);

  int get hashCode => Util.getHashCode([header, content]);

  bool operator ==(other) {
    return other is Section && header == other.header && content == other.content;
  }

  String toString() => '"$header" - "$content"';
}

class SectionSplitter extends Converter<String, List<Section>> {
  final Pattern pattern;

  SectionSplitter(this.pattern);

  List<Section> convert(String data) {
    var lines = new List<Section>();

    _SectionSplitterSink._addSlice(pattern, data, true, lines.add);

    return lines;
  }

  ChunkedConversionSink startChunkedConversion(ChunkedConversionSink<Section> sink) {
    return new _SectionSplitterSink(pattern, sink);
  }
}

class _SectionSplitterSink extends StringConversionSinkBase {
  final Pattern _pattern;
  final ChunkedConversionSink<Section> _sink;

  String _carry;

  _SectionSplitterSink(this._pattern, this._sink);

  void addSlice(String chunk, int start, int end, bool isLast) {

    chunk = chunk.substring(start, end);
    if(_carry != null) {
      chunk = _carry + chunk.substring(start, end);
      _carry = null;
    }
    _carry = _addSlice(_pattern, chunk, isLast, _sink.add);
    if(isLast) _sink.close();
  }

  void close() {
    addSlice('', 0, 0, true);
  }

  static String _addSlice(Pattern pattern, String chunk, bool isLast,
                          void adder(Section record)) {
    int start = 0;
    int lastStart = 0;
    var match = _getFirstMatch(pattern, chunk, start);

    String header = null;
    String content = null;

    while(match != null) {
      content = chunk.substring(start, match.start);

      if(content.isNotEmpty) {
        var section = new Section(header, content);
        adder(section);
        content = null;
      }

      header = chunk.substring(match.start, match.end);

      lastStart = match.start;
      start = match.end;
      match = _getFirstMatch(pattern, chunk, start);
    }

    if(isLast) {
      var section = new Section(header, chunk.substring(start));
      adder(section);
      return null;
    } else {
      var carry = chunk.substring(lastStart);
      return carry;
    }
  }

  static Match _getFirstMatch(Pattern pattern, String str, int start) {
    var matches = pattern.allMatches(str)
        .where((Match m) => m.start >= start)
        .take(1)
        .toList();

    assert(matches.length <= 1);
    if(matches.isEmpty){
      return null;
    }
    return matches[0];
  }
}

