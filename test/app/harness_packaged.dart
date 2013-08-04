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

  group('storage', () {
    group('memory', () {
      storage.main();
    });

    group('sessionStorage', () {
      var store = new StringStorage(window.sessionStorage);
      storage.main(store);
    });

    group('chrome Storage', () {
      var store = new chrome.PackagedStorage();
      storage.main(store);
    });
  });

}
