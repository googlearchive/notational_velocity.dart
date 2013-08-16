library nv.element_interfaces;

// PolymerBug: https://github.com/GoogleChrome/notational_velocity.dart/issues/5
// Why can't I just use the type directly?

abstract class EditorInterface {
  String get text;
  void set text(String val);

  bool get enabled;
  void set enabled(bool val);
}
