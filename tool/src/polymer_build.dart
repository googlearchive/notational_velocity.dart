library nv.tool.polymer_build;

import 'dart:async';
import 'package:polymer/builder.dart' as cb;

Future<bool> build(String entryPoint, String outputDir) {
  var args = ['--out', outputDir, '--deploy'];
  var options = cb.parseOptions(args);
  return cb.build(entryPoints: [entryPoint], options: options)
      .then((_) => true);
}
