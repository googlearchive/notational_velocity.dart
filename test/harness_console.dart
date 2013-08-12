library harness_console;

import 'package:unittest/unittest.dart';
import 'package:unittest/vm_config.dart';
import 'package:nv/src/storage.dart';

import 'test_dump_render_tree.dart' as drt;
import 'harness_shared.dart' as shared;


main() {
  testCore(new VMConfiguration());
}

void testCore(Configuration config) {
  unittestConfiguration = config;
  groupSep = ' - ';

  shared.main( { 'memory': new StringStorage.memory()} );
  drt.main();
}
