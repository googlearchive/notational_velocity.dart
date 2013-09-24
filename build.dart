#!/usr/bin/env dart

import 'dart:io';
import 'package:polymer/builder.dart';

void main() {
  var args = new Options().arguments;
  args.addAll(['--out', 'build']);

  var options = parseOptions(args);

  build(entryPoints: ['web/index.html'], options: options);
}
