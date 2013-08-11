import 'package:polymer/polymer.dart';
import 'package:nv/src/controllers.dart';
import 'package:nv/init.dart' as init;

@CustomTag('app-element')
class AppElement extends PolymerElement {
  bool get applyAuthorStyles => true;


  AppController get appModel => init.appModel;

}
