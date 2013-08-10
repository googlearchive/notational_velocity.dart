library nv.shared;

import 'dart:async';
import 'dart:collection';
import 'package:observe/observe.dart';

part 'shared/read_only_observable_list.dart';

class NVError extends Error {
  final String message;

  NVError(this.message) {
    assert(message != null);
    assert(message.isNotEmpty);
  }

  String toString() => 'NVError: $message';
}
