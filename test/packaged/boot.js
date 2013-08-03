chrome.app.runtime.onLaunched.addListener(function() {
  chrome.app.window.create('packaged/harness_packaged.html', {
    'bounds': {
      'width': 1024,
      'height': 768
    }
  });
});
