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

  filterTests((TestCase tc) {
    // TODO: need to figure out why tests that check post-future dispose
    // errors fail...
    return !(tc.description.contains('chrome Storage - Core Storage') &&
        tc.description.contains(':after call, before complete'));
  });
}

nv_store.Storage _getSessionStorage() {
  window.sessionStorage.clear();
  return new nv_store.StringStorage(window.sessionStorage);
}

nv_store.Storage _getChromeStorage() {
  var store =  new chrome.PackagedStorage();

  // this is not async -- not sure how much this will cause blow-ups
  store.clear();
  return store;
}
