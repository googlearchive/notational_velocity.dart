library app_bootstrap;

import 'package:polymer/polymer.dart';
import 'dart:mirrors' show currentMirrorSystem;

import 'init.dart' as i0;
import 'package:nv/elements/editor_element.dart' as i1;
import 'package:nv/elements/note_row_element.dart' as i2;
import 'package:nv/elements/app_element.dart' as i3;
import 'index.html.0.dart' as i4;

void main() {
  initPolymer([
      'init.dart',
      'package:nv/elements/editor_element.dart',
      'package:nv/elements/note_row_element.dart',
      'package:nv/elements/app_element.dart',
      'index.html.0.dart',
    ], currentMirrorSystem().isolate.rootLibrary.uri.toString());
}
