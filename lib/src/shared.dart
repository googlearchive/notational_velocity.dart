library nv.shared;

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:bot/bot.dart';
import 'package:observe/observe.dart';

part 'shared/read_only_observable_list.dart';
part 'shared/split.dart';

class NVError extends Error {
  final String message;

  NVError(this.message) {
    assert(message != null);
    assert(message.isNotEmpty);
  }

  String toString() => 'NVError: $message';
}
