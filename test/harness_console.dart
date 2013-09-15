library harness_console;

import 'package:bot_io/bot_io.dart';
import 'package:logging/logging.dart';
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

  //
  // Logging
  //
  Logger.root.onRecord
    .where((LogRecord record) => record.loggerName != 'hop')
    .listen((LogRecord record) {
      var output = '${record.level}\t${record.loggerName}\t${record.message}';
      output = AnsiColor.CYAN.wrap(output);
      print(output);
    });
}
