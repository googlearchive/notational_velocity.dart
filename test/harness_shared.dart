library harness_shared;

import 'shared/_shared.dart' as shared;
import 'nv/test_storage.dart' as storage;

void main(Map<String, storage.StorageFactory> factories) {
  storage.testStorage(factories);
  shared.main();
}
