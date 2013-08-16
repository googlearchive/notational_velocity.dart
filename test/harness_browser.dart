library harness_browser;

import 'dart:html';
import 'package:unittest/html_enhanced_config.dart';
import 'package:unittest/unittest.dart';

import 'package:nv/src/storage.dart';
import 'harness_shared.dart' as shared;

main() {
  groupSep = ' - ';
  useHtmlEnhancedConfiguration();

  shared.main({
    'localStorage': new StringStorage(window.localStorage),
    'sessionStorage': new StringStorage(window.sessionStorage)
  });

}
