library harness_shared;

import 'package:nv/src/storage.dart';

import 'shared/_shared.dart' as shared;
import 'nv/test_storage.dart' as storage;

void main(Map<String, Storage> stores) {
  storage.testStorage(stores);
  shared.main();
}
