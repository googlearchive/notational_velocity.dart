library harness_console;

import 'package:unittest/unittest.dart';
import 'package:unittest/vm_config.dart';
import 'package:nv/src/storage.dart';

import 'nv/test_storage.dart' as storage;
import 'test_dump_render_tree.dart' as drt;
import 'tool/split_tests.dart' as split;

main() {
  testCore(new VMConfiguration());
}

void testCore(Configuration config) {
  unittestConfiguration = config;
  groupSep = ' - ';

  storage.main(new StringStorage.memory());
  split.main();
  drt.main();
}
