
if (navigator.webkitStartDart) {
  navigator.webkitStartDart();
} else {
  var script = document.createElement('script');
  script.src = 'chrome_app.dart.precompiled.js';
  document.body.appendChild(script);
}
