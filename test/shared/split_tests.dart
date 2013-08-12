library test.nv.tool.chrome;

import 'dart:async';
import 'package:unittest/unittest.dart';
import 'package:nv/src/shared.dart';

void main() {
  test('test parsing', () {

    var regexp = new RegExp(r'^#\d+', multiLine: true);

    var expected = [new Section(null, "silly prefix\n\n"),
                    new Section('#1', "one content here with #2 to ignore\n"),
                    new Section('#20', "two content here and back to #1 to"
                        " ignore\n\nand this #1000 to ignore :-)\n"),
                    new Section('#300', 'three and final content herecool here'
                        ', though\n\n\ntill the end')
    ];

    return _test(_splitData, regexp, expected);
  });
}

Future _test(String input, RegExp regexp, List<Section> expectedResults) {

  var splitter = new SectionSplitter(regexp);
  var result = splitter.convert(input);


  expect(result, orderedEquals(expectedResults));
}

const _splitData = '''silly prefix

#1one content here with #2 to ignore
#20two content here and back to #1 to ignore

and this #1000 to ignore :-)
#300three and final content herecool here, though


till the end''';