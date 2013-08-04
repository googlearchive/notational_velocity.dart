library harness_browser;

import 'dart:html';
import 'package:unittest/html_enhanced_config.dart';
import 'package:unittest/unittest.dart';

import 'package:nv/src/storage.dart';
import 'package:nv/src/chrome.dart' as chrome;
import '../nv/test_storage.dart' as storage;

main() {
  groupSep = ' - ';
  useHtmlEnhancedConfiguration();

  storage.testStorage({
    'memory': new StringStorage.memory(),
    'sessionStorage': new StringStorage(window.sessionStorage),
    'chrome Storage':new chrome.PackagedStorage()
  });
}
