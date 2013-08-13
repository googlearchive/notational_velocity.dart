library harness_shared;

import 'package:nv/src/storage.dart';

import 'nv/test_app_model.dart' as app_model;
import 'shared/_shared.dart' as shared;
import 'nv/test_storage.dart' as storage;
import 'nv/test_sync.dart' as sync;

void main(Map<String, Storage> stores) {
  app_model.main();
  storage.testStorage(stores);
  shared.main();

  // TODO: wrap this into the storage tests
  sync.main(new StringStorage.memory());
}
