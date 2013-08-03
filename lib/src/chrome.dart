library nv.chrome;

import 'dart:async';

import 'package:meta/meta.dart';
import 'package:js/js.dart' as js;
import 'dart:json' as JSON;
import 'storage.dart';

class PackagedStorage implements Storage {

  @override
  Future clear() {
    final completer = new Completer();

    js.scoped(() {
      final onDone = new js.Callback.once(() => completer.complete());

      _localProxy['clear'](onDone);
    });

    return completer.future;
  }

  @override
  Future set(String key, dynamic value) {
    var map = new Map<String, dynamic>()
        ..[key] = JSON.stringify(value);

    final completer = new Completer();

    js.scoped(() {

      final onDone = new js.Callback.once(completer.complete);

      _localProxy['set'](js.map(map), onDone);
    });

    return completer.future;
  }

  @override
  Future<dynamic> get(String key) {
    final completer = new Completer();

    js.scoped(() {
      final onDone = new js.Callback.once((Map values) {
        String value = values[key];

        var val = (value == null) ? null : JSON.parse(value);

        completer.complete(val);
      });

      _localProxy['get'](key, onDone);
    });

    return completer.future;
  }

  Future remove(String key) {
    final completer = new Completer();

    js.scoped(() {
      final onDone = new js.Callback.once(completer.complete);

      _localProxy['remove'](key, onDone);
    });

    return completer.future;
  }

  js.Proxy get _localProxy => js.context['chrome']['storage']['local'];

}
