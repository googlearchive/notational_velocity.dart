library harness_console;

import 'package:unittest/unittest.dart';
import 'package:unittest/compact_vm_config.dart';

import 'test_dump_render_tree.dart' as drt;
import 'harness_shared.dart' as shared;


void main() {
  testCore(new CompactVMConfiguration());
}

void testCore(Configuration config) {
  unittestConfiguration = config;
  groupSep = ' - ';

  shared.main( {} );
  drt.main();
}
