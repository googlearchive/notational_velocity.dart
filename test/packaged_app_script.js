chrome.app.runtime.onLaunched.addListener(function() {
  chrome.app.window.create('harness_browser.html', {
    'bounds': {
      'width': 400,
      'height': 500
    }
  });
});
