library nv.debug;

import 'dart:async';
import 'src/controllers.dart';
import 'src/models.dart';
import 'src/serialization.dart';
import 'src/storage.dart';
import 'src/sync.dart';


part 'src/debug/pride_and_prejudice.dart';
part 'src/debug/debug_vm.dart';

Future<AppController> getDebugController() {
  var storage = new StringStorage.memoryDelayed();

  return MapSync.createAndLoad(storage, NOTE_CODEC)
    .then((MapSync<Note> ms) => new AppController(ms));
}
