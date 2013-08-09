import 'package:polymer/polymer.dart';
import 'package:nv/src/models.dart';
import 'package:nv/debug.dart';

@CustomTag('debug-element')
class DebugElement extends PolymerElement with ChangeNotifierMixin {
  static const _APP_MODEL = const Symbol('appModel');

  DebugVM _vm;

  void set appModel(AppModel value) {
    assert(_vm == null);
    assert(value != null);
    _vm = new DebugVM(value);

    notifyChange(new PropertyChangeRecord(_APP_MODEL));
  }

  AppModel get appModel {
    return _vm == null ? null : _vm.appModel;
  }
}
