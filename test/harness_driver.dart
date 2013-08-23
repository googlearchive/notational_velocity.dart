import 'package:webdriver/webdriver.dart';
import 'package:unittest/unittest.dart';

main() {

  group('Window', () {

    WebDriver driver;

    setUp(() {
      return WebDriver.createDriver(desiredCapabilities: Capabilities.chrome)
          .then((_driver) => driver = _driver);
    });

    tearDown(() => driver.quit());

    test('size', () {
      return driver.window.setSize(new Size(400, 600))
          .then((_) => driver.window.size)
          .then((size) {

            expect(size.height, 400);
            expect(size.width, 600);
          });
    });
  });
}
