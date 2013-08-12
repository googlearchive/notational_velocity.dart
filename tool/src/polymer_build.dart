library nv.tool.polymer_build;

import 'dart:async';
import 'package:polymer/component_build.dart' as cb;

Future<bool> build(List<String> args, List<String> inputs) {
  return cb.build(args, inputs)
      .then((results) => results.every((r) => r.success));
}
