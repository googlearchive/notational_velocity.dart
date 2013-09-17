part of nv.shared;

/**
 * Kevin Universal Identifier
 *
 * Format of a UUID, but not making the promises of the "standard" UUID.
 */
class _KUIDFactory {
  static _KUIDFactory _instance;
  static final _rnd = new math.Random();

  static _KUIDFactory get instance {
    if(_instance == null) {
      _instance = new _KUIDFactory.core(_getBytes());
    }
    return _instance;
  }

  final typed.Uint8List _bytes;

  fixed.Int32 _counter = fixed.Int32.MIN_VALUE;

  _KUIDFactory.core(this._bytes) {
    assert(_bytes.length == 12);
  }

  KUID next() {

    var sha256 = new crypto.SHA256()
      ..add(_bytes)
      ..add(_getBytes())
      ..add(_counter.toBytes());

    _counter++;

    var bytes = sha256.close();

    return new KUID(bytes.sublist(0, 16));
  }

  static typed.Uint8List _getBytes() {
    var list = new typed.Uint8List(12);
    list.setRange(0, 8, _getTimeStamp());
    list.setRange(8, 12, _getRnd());
    return list;
  }

  static List<int> _getRnd() =>
      new fixed.Int32.fromInt(_rnd.nextInt(4294967295)).toBytes();

  static List<int> _getTimeStamp() =>
      new fixed.Int64.fromInt(new DateTime.now().millisecondsSinceEpoch).toBytes();
}

class KUID extends Object with ComparableMixin<KUID> {
  final typed.Uint8List _bytes;
  final UnmodifiableListView<int> bytes;

  factory KUID.next() => _KUIDFactory.instance.next();

  factory KUID(List<int> bytes) {
    return new KUID._typed(new typed.Uint8List.fromList(bytes));
  }

  factory KUID.parse(String value) {
    requireArgumentContainsPattern(_regExp, value, 'value');
    value = value.toLowerCase().replaceAll('-', '');
    assert(value.length == 32);
    var bytes = new typed.Uint8List(16);

    for(var i = 0; i < bytes.length; i++) {
      var sub = value.substring(i*2, i*2+2);
      bytes[i] = int.parse(sub, radix: 16);
    }
    return new KUID._typed(bytes);
  }

  KUID._typed(typed.Uint8List bytes) :
    this._bytes = bytes,
    this.bytes = new UnmodifiableListView(bytes) {
    requireArgument(bytes.length == 16, 'bytes', 'Must have length 16');
  }

  int get hashCode => Util.getHashCode(_bytes);

  int compareTo(KUID other) {
    int compare;
    for(var i = 0; i < 16; i++) {
      compare = _bytes[i].compareTo(other.bytes[i]);
      if(compare != 0) return compare;
    }
    return compare;
  }

  String toString() {
    var buffer = new StringBuffer();
    _writebytesToHex(buffer, _bytes, 0, 4);
    buffer.write('-');
    _writebytesToHex(buffer, _bytes, 4, 6);
    buffer.write('-');
    _writebytesToHex(buffer, _bytes, 6, 8);
    buffer.write('-');
    _writebytesToHex(buffer, _bytes, 8, 10);
    buffer.write('-');
    _writebytesToHex(buffer, _bytes, 10, 16);
    return buffer.toString();
  }

  static void _writebytesToHex(StringSink sink, List<int> bytes, int start, int end) {
    for (var i = start; i < end; i++) {
      var part = bytes[i];
      sink.write('${part < 16 ? '0' : ''}${part.toRadixString(16)}');
    }
  }

  static final _regExp = new RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$', multiLine: false, caseSensitive: false);
}

/**
 * It might make sense to implement some or all of these operators explicitly
 * for performance reasons.
 *
 * But having a clean, default impl is pretty nice.
 *
 * Don't forget to implement [hashCode] as well.
 */
abstract class ComparableMixin<E> implements Comparable<E> {

  bool operator<(E other) => this.compareTo(other) < 0;

  bool operator<=(E other) => this.compareTo(other) <= 0;

  bool operator>(E other) => this.compareTo(other) > 0;

  bool operator>=(E other) => this.compareTo(other) >= 0;

  @override
  bool operator==(Object other) => other is E && this.compareTo(other) == 0;
}
