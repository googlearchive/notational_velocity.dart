library harness_browser;

import 'dart:html';
import 'package:unittest/html_enhanced_config.dart';
import 'package:unittest/unittest.dart';

import 'package:nv/src/storage.dart';
import 'nv/test_storage.dart' as storage;

main() {
  groupSep = ' - ';
  useHtmlEnhancedConfiguration();

  storage.testStorage({
    'memory': new StringStorage.memory(),
    'localStorage': new StringStorage(window.localStorage),
    'sessionStorage': new StringStorage(window.sessionStorage)
  });
}
