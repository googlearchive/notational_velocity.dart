library nv.element_interfaces;

import 'package:polymer/polymer.dart';

// PolymerBug: https://github.com/GoogleChrome/notational_velocity.dart/issues/5
// Why can't I just use the type directly?

abstract class EditorInterface implements Observable {
  String get text;
  void set text(String val);

  bool get enabled;
  void set enabled(bool val);

  void focusText();
}
