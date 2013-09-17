library test.nv.shared.kuid;

import 'dart:math' as math;
import 'package:nv/src/shared.dart';
import 'package:unittest/unittest.dart';

void main() {
  test('binary', () {
    var bytes = new List.filled(16, 0);

    var uuid = new KUID(bytes);
    expect(uuid.toString(), '00000000-0000-0000-0000-000000000000');

    bytes[15] = 1;
    uuid = new KUID(bytes);
    expect(uuid.toString(), '00000000-0000-0000-0000-000000000001');

    bytes[0] = 16;
    bytes[1] = 255;
    uuid = new KUID(bytes);
    expect(uuid.toString(), '10ff0000-0000-0000-0000-000000000001');

    bytes.fillRange(0, 16, 255);
    uuid = new KUID(bytes);
    expect(uuid.toString(), 'ffffffff-ffff-ffff-ffff-ffffffffffff');

    bytes[0] = 256;
    bytes[1] = 257;
    bytes[2] = 258;
    bytes[3] = 512;
    uuid = new KUID(bytes);
    expect(uuid.bytes[0], 0, reason: 'overflow wraps');
    expect(uuid.bytes[1], 1, reason: 'overflow wraps');
    expect(uuid.bytes[2], 2, reason: 'overflow wraps');
    expect(uuid.bytes[3], 0, reason: 'overflow wraps');
  });

  test('equals, compare, simple', () {
    var bytes = new List.filled(16, 0);

    var first = new KUID(bytes);
    var firstClone = new KUID(bytes);

    bytes.fillRange(0, 16, 255);
    var last = new KUID(bytes);

    expect(first, same(first));
    expect(first, equals(first));
    expect(first, equals(firstClone));
    expect(first, isNot(same(firstClone)));

    expect(first.compareTo(firstClone), 0);
    expect(first.compareTo(last), lessThan(0));
    expect(last.compareTo(first), greaterThan(0));
    expect(last.compareTo(last), 0);

    _expectCompareOperators(first, first);
    _expectCompareOperators(first, firstClone);
    _expectCompareOperators(last, first);
    _expectCompareOperators(first, last);
  });

  test('sort', () {
    var bytes = new List.filled(16, 0);

    var first = new KUID(bytes);

    bytes.fillRange(0, 16, 255);
    var last = new KUID(bytes);

    var items = [first, last];

    var rnd = new math.Random();

    for(var i = 0; i < 100; i++) {

      for(var j = 0; j < bytes.length; j++) {
        bytes[j] = rnd.nextInt(256);
        assert(bytes[j] >= 0 && bytes[j] < 256);
      }

      items.add(new KUID(bytes));
    }

    items.sort();

    for(var i = 0; i < (items.length - 1); i++) {
      expect(items[i], lessThanOrEqualTo(items[i+1]));
      expect(items[i+1], greaterThanOrEqualTo(items[i]));
    }

    // strings sort same as items
    var strings = items.map((e) => e.toString()).toList(growable: false);
    strings.sort();

    expect(strings, orderedEquals(items.map((e) => e.toString()).toList(growable: false)));
  });

  test('basic', () {

    var next = new KUID.next();
    var roundTrip = new KUID.parse(next.toString());

    expect(roundTrip, next);
    expect(roundTrip.hashCode, next.hashCode);


  });

  test('unique', () {
    var list = new List<KUID>();
    var set = new Set<KUID>();

    for(var i = 0; i < _UNIQUE_COUNT; i++) {
      var uuid = new KUID.next();
      list.add(uuid);
      set.add(uuid);
    }

    // dupes would be ignored, leaving less than the expecetd length
    expect(set, hasLength(_UNIQUE_COUNT));

    list.forEach((e) {
      // a simple way to validate the hashCode impl
      expect(set, contains(e));
    });

  });

  test("round-trip known", () {

    for(var v in _known) {
      var uuid = new KUID.parse(v);

      expect(uuid.toString(), v.toLowerCase());

      var roundTrip = new KUID.parse(uuid.toString());

      expect(roundTrip, uuid);
      expect(roundTrip.hashCode, uuid.hashCode);
    }

  });
}

_expectCompareOperators(ComparableMixin a, ComparableMixin b) {
  final int compare = a.compareTo(b);

  expect(a < b, compare < 0);
  expect(a <= b, compare <= 0);
  expect(a == b, compare == 0);
  expect(a >= b, compare >= 0);
  expect(a > b, compare > 0);
}

const _UNIQUE_COUNT = 1000;

const _known = const['550e8400-e29b-41d4-a716-446655440000',
                     '00000000-0000-0000-0000-000000000000',
                     'ffffffff-ffff-ffff-ffff-ffffffffffff',
                     'FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF'];
