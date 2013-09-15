library harness_browser;

import 'dart:html';
import 'package:unittest/html_enhanced_config.dart';
import 'package:unittest/unittest.dart';

import 'package:nv/src/storage.dart' as nv_store;
import 'package:nv/src/chrome.dart' as chrome;
import '../harness_shared.dart' as shared;

void main() {
  groupSep = ' - ';
  useHtmlEnhancedConfiguration();

  shared.main({
    'sessionStorage': _getSessionStorage,
    'chrome Storage': _getChromeStorage
  });
}

nv_store.Storage _getSessionStorage() {
  window.sessionStorage.clear();
  return new nv_store.StringStorage(window.sessionStorage);
}

nv_store.Storage _getChromeStorage() {
  // TODO: need to clear out this sucker
  return new chrome.PackagedStorage();
}
