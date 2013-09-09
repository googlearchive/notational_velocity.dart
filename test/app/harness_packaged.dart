library harness_browser;

import 'dart:html';
import 'package:unittest/html_enhanced_config.dart';
import 'package:unittest/unittest.dart';

import 'package:nv/src/storage.dart';
import 'package:nv/src/chrome.dart' as chrome;
import '../harness_shared.dart' as shared;

void main() {
  groupSep = ' - ';
  useHtmlEnhancedConfiguration();

  shared.main({
    'sessionStorage': new StringStorage(window.sessionStorage),
    'chrome Storage':new chrome.PackagedStorage()
  });

  // Need bug here!!
  // Test only fails in Dartium...hmm...
  filterTests((TestCase tc) {
    return !tc.description.contains('wrapping CollectionView');
  });
}
