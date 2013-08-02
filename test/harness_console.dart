library harness_console;

import 'package:unittest/unittest.dart';
import 'package:unittest/vm_config.dart';

import 'nv/test_storage.dart' as storage;
import 'test_dump_render_tree.dart' as drt;

main() {
  testCore(new VMConfiguration());
}

void testCore(Configuration config) {
  unittestConfiguration = config;
  groupSep = ' - ';

  storage.main();
  drt.main();
}
