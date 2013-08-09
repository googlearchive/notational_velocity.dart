import 'package:polymer/polymer.dart';
import 'package:nv/src/models.dart';
import 'package:nv/init.dart' as init;

@CustomTag('app-element')
class AppElement extends PolymerElement {
  bool get applyAuthorStyles => true;


  AppModel get appModel => init.appModel;

}
