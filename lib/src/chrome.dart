library nv.chrome;

import 'dart:async';

import 'dart:json' as JSON;
import 'package:bot/bot.dart';
import 'package:js/js.dart' as js;
import 'package:js/js_wrapping.dart' as wrapping;
import 'storage.dart';

class PackagedStorage implements Storage {
  bool _isDisposed = false;

  bool get isDisposed => _isDisposed;

  Future clear() {
    _requireNotDisposed();
    final completer = new Completer();

    js.scoped(() {
      final onDone = new js.Callback.once(() => completer.complete());

      _localProxy['clear'](onDone);
    });

    return completer.future;
  }

  Future set(String key, dynamic value) {
    _requireNotDisposed();
    if(value == null) return remove(key);

    var map = new Map<String, dynamic>()
        ..[key] = JSON.stringify(value);

    final completer = new Completer();

    js.scoped(() {

      final onDone = new js.Callback.once(completer.complete);

      _localProxy['set'](js.map(map), onDone);
    });

    return completer.future;
  }

  Future<dynamic> get(String key) {
    return _get(key)
        .then((String jsonString) {
          var val = (jsonString == null) ? null : JSON.parse(jsonString);
          return val;
      });
  }

  Future<bool> exists(String key) =>
    _get(key).then((String jsonString) => jsonString != null);

  Future remove(String key) => _remove([key]);

  Future<List<String>> getKeys() {
    _requireNotDisposed();
    final completer = new Completer<List<String>>();

    js.scoped(() {
      final onDone = new js.Callback.once((js.Proxy values) {

        var map = wrapping.JsObjectToMapAdapter.cast(values);
        var keys = map.keys.toList();
        completer.complete(keys);
      });

      _localProxy['get'](null, onDone);
    });

    return completer.future;
  }

  Future addAll(Map<String, dynamic> values) {
    _requireNotDisposed();
    var map = new Map<String, dynamic>();
    var removes = [];
    values.forEach((k, v) {
      if(v == null) {
        removes.add(k);
      } else {
        map[k] = JSON.stringify(v);
      }
    });

    return _remove(removes)
        .then((_) {

          final completer = new Completer();

          js.scoped(() {
            final onDone = new js.Callback.once(completer.complete);
            _localProxy['set'](js.map(map), onDone);
          });

          return completer.future;
        });
  }

  void dispose() {
    _requireNotDisposed();
    _isDisposed = true;
  }

  //
  // Implementation
  //

  void _requireNotDisposed() {
    if(_isDisposed) {
      throw new DisposedError();
    }
  }

  Future<String> _get(String key) {
    _requireNotDisposed();
    final completer = new Completer();

    js.scoped(() {
      final onDone = new js.Callback.once((Map values) {
        String value = values[key];
        completer.complete(value);
      });

      _localProxy['get'](key, onDone);
    });

    return completer.future;
  }

  Future _remove(List<String> keys) {
    _requireNotDisposed();
    if(keys.isEmpty) return new Future.value(null);

    final completer = new Completer();

    js.scoped(() {
      final onDone = new js.Callback.once(completer.complete);

      _localProxy['remove'](js.array(keys), onDone);
    });

    return completer.future;
  }

  js.Proxy get _localProxy => js.context['chrome']['storage']['local'];
}
