library harness_browser;

import 'dart:html';
import 'package:unittest/html_enhanced_config.dart';
import 'package:unittest/unittest.dart';

import 'package:nv/src/storage.dart' as nv_store;
import 'harness_shared.dart' as shared;

void main() {
  groupSep = ' - ';
  useHtmlEnhancedConfiguration();

  shared.main({
    'localStorage': _getLocalStorage,
    'sessionStorage': _getSessionStorage
  });
}

nv_store.Storage _getSessionStorage() {
  window.sessionStorage.clear();
  return new nv_store.StringStorage(window.sessionStorage);
}

nv_store.Storage _getLocalStorage() {
  window.localStorage.clear();
  return new nv_store.StringStorage(window.localStorage);
}
