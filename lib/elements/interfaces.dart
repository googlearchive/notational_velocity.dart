library nv.element_interfaces;

// PolymerBug: https://github.com/GoogleChrome/notational_velocity.dart/issues/5
// Why can't I just use the type directly?

abstract class EditorInterface {
  String get value;
  void set value(String val);
}
