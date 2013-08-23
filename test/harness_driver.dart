import 'dart:async';
import 'dart:io';
import 'package:webdriver/webdriver.dart';
import 'package:unittest/unittest.dart';
import 'src/unsafe_virtual_directory.dart';

WebDriver _driver;
HttpServer _server;

void main() {
  group('server', () {
    setUp(_setup);
    tearDown(_tearDown);

    test('simple', () {
      return _driver.findElement(const By.tagName('app-element'))
          .then((WebElement e) {
            expect(e, isNotNull);
          });
    });

  });
}

// TODO: make this a config options?
const _dartiumBinary = '/usr/local/Cellar/dart-editor/26297/chromium/Chromium.app/Contents/MacOS/Chromium';

Future _setup() {
  assert(_server == null);
  return HttpServer.bind('localhost', 0)
      .then((HttpServer server) {

        var virDir = new UnsafeVirtualDirectory('web');
        virDir.allowDirectoryListing = true;
        virDir.serve(server);

        _server = server;

        var caps = Capabilities.chrome;
        caps['chromeOptions'] = { 'binary' : _dartiumBinary };

        var appUri = new Uri(scheme: 'http', host: 'localhost',
            port: server.port, path: 'index.html');

        return WebDriver.createDriver(desiredCapabilities: caps)
            .then((val) => _driver = val)
            .then((_) => _driver.get(appUri.toString()));
      });
}

Future _tearDown() {
  return Future.forEach([_server, _driver], (e) {
    if(e is HttpServer) {
      return (e as HttpServer).close();
    } else if(e is WebDriver) {
      return (e as WebDriver).quit();
    }
  })
  .whenComplete(() {
    _server = null;
    _driver = null;
  });
}
