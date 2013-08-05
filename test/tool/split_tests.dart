library test.nv.tool.chrome;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:unittest/unittest.dart';
import '../../tool/src/split.dart';

void main() {
  group('split', () {
    test('test parsing', () {

      var regexp = new RegExp(r'^#\d+', multiLine: true);

      var expected = [
                      new Section(null, """silly prefix

"""),
                      new Section('#1', """one content here with #2 to ignore
""")
                      ];

      return _test('test/data/simple_data.txt', regexp, expected);
    });
  });
}

Future _test(String inputFile, RegExp regexp, List<Section> expectedResults) {
  var file = new File(inputFile);
  assert(file.existsSync());

  return file.openRead()
      .transform(new Utf8Decoder())
      .transform(new SectionSplitter(regexp))
      .take(expectedResults.length)
      .toList()
      .then((List<Section> sections) {
        expect(sections, orderedEquals(expectedResults));
      });
}
